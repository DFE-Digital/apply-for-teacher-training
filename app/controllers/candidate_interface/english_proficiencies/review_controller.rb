module CandidateInterface
  module EnglishProficiencies
    class ReviewController < SectionController
      def show
        @section_complete_form = SectionCompleteForm.new(
          completed: current_application.efl_completed,
          )
        @return_to = return_to_after_edit(default: application_form_path)
      end

      def complete
        # @component_instance = ChooseEflReviewComponent.call(english_proficiency)
        @section_complete_form = SectionCompleteForm.new(completion_params)
        @return_to = return_to_after_edit(default: candidate_interface_details_path)

        if @section_complete_form.save(current_application, :efl_completed)
          if current_application.meets_conditions_for_adviser_interruption? && @section_complete_form.completed?
            redirect_to candidate_interface_adviser_sign_ups_interruption_path
          else
            redirect_to_candidate_root
          end
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

    private

      def completion_params
        strip_whitespace params
          .expect(candidate_interface_section_complete_form: [:completed])
      end
    end
  end
end
