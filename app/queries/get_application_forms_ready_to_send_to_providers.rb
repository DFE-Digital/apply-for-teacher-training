class GetApplicationFormsReadyToSendToProviders
  def self.call
    forms = ApplicationForm
      .joins(:application_choices)
      .where('"application_choices"."status" = ?', 'application_complete')
      .where('"application_forms"."edit_by" < ?', Time.zone.now)
      .group(:id)

    forms.select do |f|
      offered_statuses    = Set.new(f.application_choices.map(&:status))
      acceptable_statuses = Set.new(%w[application_complete cancelled])

      acceptable_statuses.superset? offered_statuses
    end
  end
end
