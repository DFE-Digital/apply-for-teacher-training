module CandidateInterface
  module PersonalDetails
    class ReviewController < SectionController
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
      end

      def create
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
          redirect_to_candidate_root
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end
    end
  end
end
