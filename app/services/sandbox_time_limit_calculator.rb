class SandboxTimeLimitCalculator
  def initialize(*); end

  def call
    [0, Time.zone.now]
  end
end
