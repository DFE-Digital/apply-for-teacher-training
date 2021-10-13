module TouchApplicationFormState
  extend ActiveSupport::Concern

  included do
    around_save do |_object, block|
      application_form = is_a?(ApplicationForm) ? self : self.application_form

      duped_form = application_form.id.nil? ? application_form.dup : ApplicationForm.find(application_form.id)
      previous_application_form_status = ProcessState.new(duped_form).state

      block.call

      current_application_form_status = ProcessState.new(ApplicationForm.find(application_form.id)).state

      candidate.update!(candidate_api_updated_at: Time.zone.now) if previous_application_form_status != current_application_form_status
    end
  end
end
