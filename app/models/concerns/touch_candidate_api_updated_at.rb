module TouchCandidateAPIUpdatedAt
  extend ActiveSupport::Concern

  included do
    around_save do |_object, block|
      application_form = is_a?(ApplicationForm) ? self : self.application_form

      previous_application_form_status = ProcessState.new(application_form).state
      block.call
      current_application_form_status = ProcessState.new(application_form).state

      candidate.update!(candidate_api_updated_at: Time.zone.now) if previous_application_form_status != current_application_form_status
    end
  end
end
