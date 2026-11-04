class UpdateTriggeredDuplicateMatchesWorker < ApplicationJob
  queue_as :low_priority

  def perform(application_form_id)
    application_form = ApplicationForm.find_by(id: application_form_id)
    return if application_form.nil?

    UpdateTriggeredDuplicateMatches.new(application_form).save!
  end
end
