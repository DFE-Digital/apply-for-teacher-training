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

    def apply_again
      DuplicateApplication.new(current_application).duplicate
      flash[:success] = 'Your new application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end

    def edit
      redirect_to candidate_interface_application_complete_path and return unless current_application.can_edit_after_submission?

      @application_form = current_application
      render :edit_by_support
    end
  end
end
