class GetApplicationChoicesReadyToSendToProvider
  def self.call
    ApplicationChoice
      .joins(application_form: :references)
      .where('feedback is not null')
      .where('edit_by < ?', Time.zone.now)
      .where(status: :application_complete)
      .group('application_choices.id')
      .having('count("references"."feedback") >= 2')
  end
end
