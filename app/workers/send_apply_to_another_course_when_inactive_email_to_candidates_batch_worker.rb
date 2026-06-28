class SendApplyToAnotherCourseWhenInactiveEmailToCandidatesBatchWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(application_ids)
    ApplicationForm.where(id: application_ids).each do |application_form|
      SendApplyToAnotherCourseWhenInactiveEmailToCandidate.call(application_form)
    end
  end
end
