module CandidateInterface
  module PersonalDetails
    class ReviewController < SectionController

      before_action :finish_immigration_status, if: -> { ImmigrationStatus.new(current_application: current_application).incomplete? }, only: :show
      def show
        @application_form = current_application
        @section_complete_form = SectionCompleteForm.new(
          completed: current_application.personal_details_completed,
        )
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
        @personal_details_review = PersonalDetailsReviewComponent.new(
          application_form: current_application,
          editable: @section_policy.can_edit?,
        )
        @immigration_right_to_work_form = ImmigrationRightToWorkForm.build_from_application(current_application)
      end

      def complete
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
        @immigration_right_to_work_form = ImmigrationRightToWorkForm.build_from_application(current_application)
        @section_complete_form = SectionCompleteForm.new(completed: application_form_params[:completed])
        @personal_details_review = PersonalDetailsReviewComponent.new(application_form: current_application)

        if all_sections_valid?
          save_section_complete_form
        else
          render :show
        end
      end

      helper_method :all_sections_valid?

    private

      def all_sections_valid?
        @personal_details_form.valid? && @nationalities_form.valid? && right_to_work_valid?
      end

      def right_to_work_valid?
        return true if current_application.british_or_irish?

        @immigration_right_to_work_form.valid?
      end

      def save_section_complete_form
        if @section_complete_form.save(current_application, :personal_details_completed)
          if current_application.meets_conditions_for_adviser_interruption? && @section_complete_form.completed?
            redirect_to candidate_interface_adviser_sign_ups_interruption_path(@current_application.id)
          else
            redirect_to_candidate_root
          end
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end

      def finish_immigration_status
        redirect_to candidate_interface_immigration_status_path
      end
    end
  end
end
