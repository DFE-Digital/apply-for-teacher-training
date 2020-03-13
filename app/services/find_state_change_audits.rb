class FindStateChangeAudits
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    []
  end
end
