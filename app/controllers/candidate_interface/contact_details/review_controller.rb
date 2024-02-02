module CandidateInterface
  class ContactDetails::ReviewController < SectionController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
      @can_complete = ContactDetailsForm.build_from_application(current_application).valid_for_submission?
      @section_complete_form = SectionCompleteForm.new(
        completed: current_application.contact_details_completed,
      )
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: application_form_params[:completed])

      if ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed) && !details_complete?
        flash[:warning] = 'You cannot mark this section complete with incomplete contact details.'
        redirect_to candidate_interface_contact_information_review_path
      elsif @section_complete_form.save(current_application, :contact_details_completed)
        redirect_to candidate_interface_continuous_applications_details_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def application_form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end

    def details_complete?
      contact_details_form.valid_for_submission?
    end

    def contact_details_form
      @contact_details_form ||=
        CandidateInterface::ContactDetailsForm.build_from_application(@application_form)
    end
  end
end
