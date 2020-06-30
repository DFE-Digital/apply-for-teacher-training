class FindStatusChangeAudits
  attr_reader :application_choice

  StatusChange = Struct.new(:status, :changed_at, :user)

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    status_audits.map { |audit| status_change_for(audit) }
  end

private

  def status_audits
    application_choice.audits.select do |audit|
      status_change?(audit)
    end
  end

  def status_change_for(audit)
    StatusChange.new(
      audit.audited_changes['status'][1],
      audit.created_at,
      audit.user || audit.username,
    )
  end

  def status_change?(audit)
    audit.action == 'update' && audit.audited_changes.key?('status')
  end
end
