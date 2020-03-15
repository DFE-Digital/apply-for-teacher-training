class FindStateChangeAudits
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    application_choice.audits.select do |audit|
      state_change?(audit)
    end
  end

private

  def state_change?(audit)
    audit.action == 'update' && audit.audited_changes.has_key?('status')
  end
end
