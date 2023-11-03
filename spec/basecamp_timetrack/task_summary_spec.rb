require "spec_helper"

RSpec.describe TaskSummary do
  describe "#+" do
    let(:task_summary1) { TaskSummary.new(title: "test 1", time_logs: [TimeLog.new("1h"), TimeLog.new("30m")]) }
    let(:task_summary2) { TaskSummary.new(title: "test 2", time_logs: [TimeLog.new("0.5h"), TimeLog.new("2h")]) }

    it do
      expect(task_summary1 + task_summary2).to eq("4.0h")
    end
  end

  describe "total sum" do
    let(:task_summary1) { TaskSummary.new(title: "test 1", time_logs: [TimeLog.new("1h"), TimeLog.new("30m")]) }
    let(:task_summary2) { TaskSummary.new(title: "test 2", time_logs: [TimeLog.new("0.5h"), TimeLog.new("2h")]) }
    let(:task_summary3) { TaskSummary.new(title: "test 3", time_logs: [TimeLog.new("1h")]) }
    let(:task_summaries) { [task_summary1, task_summary2, task_summary3] }

    it do
      expect(task_summaries.map(&:total_time_logs).sum(TimeLog.new(0))).to eq(TimeLog.new("5.0h"))
    end
  end
end
