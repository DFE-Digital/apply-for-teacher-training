module CandidateInterface
  class SubmittedApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_application_form_unless_submitted

    def review_submitted
      @application_form = current_application
    end

    def complete
      @application_form = current_application
    end

    def submit_success
      @application_form = current_application
      @support_reference = current_application.support_reference
      @editable_days = TimeLimitConfig.edit_by
      provider_count = current_application.unique_provider_list.size
      @pluralized_provider_string = 'provider'.pluralize(provider_count)
    end
  end
end
