class SandboxTimeLimitCalculator
  def initialize(*); end

  def call
    { days: 0, time_in_future: Time.zone.now }
  end
end
