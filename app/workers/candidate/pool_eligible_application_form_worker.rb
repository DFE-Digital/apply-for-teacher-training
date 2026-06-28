class Candidate::PoolEligibleApplicationFormWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    application_forms = Pool::Candidates.new.application_forms_in_the_pool.select(:id)

    return if application_forms.blank?

    application_forms.in_batches.each do |batch|
      batch.each do |application_form|
        PoolEligibleApplicationForm.create(application_form_id: application_form.id)
      end
    end
  end
end
