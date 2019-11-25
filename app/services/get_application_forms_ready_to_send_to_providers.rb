class GetApplicationFormsReadyToSendToProviders
  def self.call
    forms = ApplicationForm
      .joins(:application_choices)
      .where('"application_choices"."status" = ?', 'application_complete')
      .having('max("application_choices"."edit_by") < ?', Time.zone.now)
      .group(:id)

    forms.select do |f|
      f.application_choices.all? { |application_choice| application_choice.status == 'application_complete' }
    end
  end
end
