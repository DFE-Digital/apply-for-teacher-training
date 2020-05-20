class GetApplicationFormsReadyToSendToProviders
  def self.call
    forms = if FeatureFlag.active?('move_edit_by_to_application_form')
              ApplicationForm
                .joins(:application_choices)
                .where('"application_choices"."status" = ?', 'application_complete')
                .where('"application_forms"."edit_by" < ?', Time.zone.now)
            else
              ApplicationForm
               .joins(:application_choices)
               .where('"application_choices"."status" = ?', 'application_complete')
               .having('max("application_choices"."edit_by") < ?', Time.zone.now)
               .group(:id)
            end

    forms.select do |f|
      f.application_choices.all? { |application_choice| application_choice.status == 'application_complete' }
    end
  end
end
