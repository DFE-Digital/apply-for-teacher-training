class GetApplicationChoicesReadyToSendToProvider
  def self.call
    application_choices_past_edit_by(
      application_choices_with_references_complete(
        ApplicationChoice.where(status: :application_complete),
      ),
    )
  end

  def self.application_choices_past_edit_by(scope)
    scope.where('edit_by < ?', Time.zone.now)
  end

  def self.application_choices_with_references_complete(scope)
    scope
      .joins(application_form: :references)
      .where('feedback is not null')
      .group('application_choices.id')
      .having('count("references"."feedback") >= ?', ApplicationForm::MINIMUM_REFERENCES)
  end
end
