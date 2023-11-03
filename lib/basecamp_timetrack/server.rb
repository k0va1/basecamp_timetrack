require "socket"
require "uri"
require "cgi"

module BasecampTimetrack
  class Server
    def start
      server = TCPServer.new 9876
      while connection = server.accept
        request = connection.gets
        data = handle(request)
        connection.puts "OAuth request received. You can close this window now."
        connection.close
        return data if data
      end
    end

    private

    def handle(request)
      _, full_path = request.split(" ")
      path = URI(full_path).path

      case path
      when "/callback"
        handle_authorize(full_path)
      when "/token"
        handle_token(full_path)
      end
    end

    def handle_authorize(full_path)
      params = CGI.parse(URI.parse(full_path).query)

      params["code"][0]
    end

    def handle_token(full_path)
      puts "token"
      params = CGI.parse(URI.parse(full_path).query)

      params["code"][0]
      "a"
    end
  end
end
