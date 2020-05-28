class GetApplicationFormsReadyToSendToProviders
  def self.call
    forms = ApplicationForm
      .joins(:application_choices)
      .where('"application_choices"."status" = ?', 'application_complete')
      .where('"application_forms"."edit_by" < ?', Time.zone.now)

    forms.select do |f|
      f.application_choices.all? { |application_choice| application_choice.status == 'application_complete' }
    end
  end
end
