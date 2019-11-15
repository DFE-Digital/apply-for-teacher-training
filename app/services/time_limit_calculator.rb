class TimeLimitCalculator
  attr_accessor :rule, :effective_date

  def initialize(rule:, effective_date:)
    self.rule = rule
    self.effective_date = effective_date
  end

  def call
    0
  end
end
