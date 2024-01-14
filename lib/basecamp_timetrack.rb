# frozen_string_literal: true

require "oauth2"
require "launchy"
require "faraday"
require "tty-table"
require "invoice_printer"
require "date"

require_relative "basecamp_timetrack/version"
require_relative "basecamp_timetrack/server"
require_relative "basecamp_timetrack/time_log"
require_relative "basecamp_timetrack/task_summary"

# TODO: remember/refresh token
module BasecampTimetrack
  class Error < StandardError; end
  CONTENT_REGEX = %r{<div>\s*(?<input>#{TimeLog::LOG_REGEX})\s*</div>}

  class << self
    def run(from: Date.today)
      client_id = ENV.fetch("CLIENT_ID")
      client_secret = ENV.fetch("CLIENT_SECRET")

      server = Thread.new do
        Server.new.start
      end

      client = OAuth2::Client.new(
        client_id,
        client_secret,
        site: "https://launchpad.37signals.com",
        authorize_url: "/authorization/new",
        token_url: "/authorization/token"
      )
      url = client.auth_code.authorize_url(redirect_uri: "http://localhost:9876/callback", type: "web_server")

      Launchy.open(url)

      code = server.value
      access = client.auth_code.get_token(
        code,
        redirect_uri: "http://localhost:9876/callback",
        type: "web_server",
        client_id:,
        client_secret:
      )
      token = access.token

      resp = access.get("authorization.json", headers: { "Authorization" => "Bearer #{token}" })
      parsed_response = JSON.parse(resp.body)
      account_id = parsed_response["accounts"][0]["id"]

      @conn = Faraday.new(
        url: "https://3.basecampapi.com/#{account_id}",
        headers: {
          "Authorization" => "Bearer #{token}",
          "User-Agent" => "Calc work time (al3xander.koval@gmail.com)"
        }
      )

      all_comments = []
      ENV.fetch("PROJECT_IDS").split(",").each do |id|
        all_comments += get_comments(id)
      end
      filtered_comments = all_comments.select { |c| Date.parse(c["created_at"]) >= from }

      comments_grouped_by_tasks = filtered_comments.group_by { |c| c["parent"]["title"] }
      task_summaries = comments_grouped_by_tasks.map do |title, comments|
        time_logs = comments.map do |c|
          input = c["content"].scan(CONTENT_REGEX).flatten.first
          TimeLog.new(input)
        end
        TaskSummary.new(title: title, time_logs: time_logs)
      end
      puts render_table(task_summaries)

      total_hours = task_summaries.map(&:total_time_logs).sum(TimeLog.new(0)).hours
      puts "TOTAL HOURS: #{total_hours}"

      generate_invoice(task_summaries)

      server.join
    end

    def render_table(task_summaries)
      table_values = task_summaries.map { |ts| [ts.title, ts.total_hours] }
      table = TTY::Table.new ["Task title", "Total hours"], table_values
      table.render(:unicode) do |renderer|
        renderer.border.separator = :each_row
      end
    end

    def generate_invoice(task_summaries)
      rate = 50
      total = 0

      items = task_summaries.map do |ts|
        total += ts.hours_in_float * rate
        InvoicePrinter::Document::Item.new(
          name: ts.title,
          quantity: ts.hours_in_float,
          unit: "h",
          price: "$ #{rate}",
          amount: "$ #{(ts.hours_in_float * rate).ceil(2)}"
        )
      end

      invoice = InvoicePrinter::Document.new(
        number: "NO. 00#{Time.now.month - 1}",
        provider_name: ENV.fetch("PROVIDER_NAME"),
        provider_lines: ENV.fetch("PROVIDER_LINES"),
        purchaser_name: ENV.fetch("PURCHASER_NAME"),
        purchaser_lines: ENV.fetch("PURCHASER_LINES"),
        issue_date: Time.now.strftime("%d/%m/%Y"),
        due_date: "05/#{Time.now.strftime("%m/%Y")}",
        total: "$ #{total.to_f.round}",
        bank_account_number: ENV.fetch("BANK_ACCOUNT_NUMBER"),
        account_iban: ENV.fetch("ACCOUNT_IBAN"),
        account_swift: ENV.fetch("ACCOUNT_SWIFT"),
        items: items
      )

      InvoicePrinter.print(
        document: invoice,
        file_name: File.expand_path("../../invoices/#{Time.now.strftime("%d_%m_%Y")}_invoice.pdf", __FILE__),
        font: "opensans"
      )
    end

    def get_comments(project_id)
      comments = []
      response = @conn.get("projects/recordings.json?type=Comment&bucket=#{project_id}")
      comments += JSON.parse(response.body)
      loop do
        link = response.headers[:link]&.scan(/<(.*)>/)&.flatten&.first
        break unless link

        response = @conn.get(link)
        comments += JSON.parse(response.body)
      end

      comments
        .select { |c| c["creator"]["email_address"] == "al3xander.koval@gmail.com" }
        .select { |c| c["content"].match?(CONTENT_REGEX) }
    end
  end
end
