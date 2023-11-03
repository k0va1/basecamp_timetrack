require "spec_helper"

RSpec.describe TimeLog do
  describe "#new" do
    it { expect(TimeLog.new("").seconds).to eq(0) }
    it { expect(TimeLog.new(nil).seconds).to eq(0) }
    it { expect(TimeLog.new(0).seconds).to eq(0) }
    it { expect(TimeLog.new("30m").seconds).to eq(1800) }
    it { expect(TimeLog.new("90m").seconds).to eq(3600 + 1800) }
    it { expect(TimeLog.new("1h30m").seconds).to eq(3600 + 1800) }
    it { expect(TimeLog.new("1h").seconds).to eq(3600) }
    it { expect(TimeLog.new("1.5h").seconds).to eq(3600 + 1800) }
    it { expect(TimeLog.new("0.5h").seconds).to eq(1800) }
    it { expect(TimeLog.new("5m").seconds).to eq(300) }
    it { expect(TimeLog.new("59m").seconds).to eq(3540) }
    it { expect(TimeLog.new("1h59m").seconds).to eq(7140) }
  end

  describe "#+" do
    it { expect(TimeLog.new("30m") + TimeLog.new("30m")).to eq(TimeLog.new("60m")) }
    it { expect(TimeLog.new("30m") + TimeLog.new("30m")).to eq(TimeLog.new("1h")) }
  end

  describe "#hours" do
    it { expect(TimeLog.new("30m").hours).to eq("0.5h") }
    it { expect(TimeLog.new("1.5h").hours).to eq("1.5h") }
    it { expect(TimeLog.new("15m").hours).to eq("0.25h") }
    it { expect(TimeLog.new("5m").hours).to eq("0.084h") }
    it { expect(TimeLog.new("1h30m").hours).to eq("1.5h") }
    it { expect(TimeLog.new("1h55m").hours).to eq("1.917h") }
  end

  describe "sum array of time logs" do
    it { expect([TimeLog.new("30m"), TimeLog.new("30m")].sum(TimeLog.new(0))).to eq(TimeLog.new("1h")) }
    it { expect([TimeLog.new("30m"), TimeLog.new("30m")].sum(TimeLog.new(0)).hours).to eq("1.0h") }
  end
end
