module CandidateInterface
  module EnglishForeignLanguage
    class ReviewController < CandidateInterfaceController
      include EflRootConcern

      before_action :check_for_english_proficiency

      def show
        @component_instance = ChooseEflReviewComponent.call(english_proficiency)
        @section_complete_form = SectionCompleteForm.new(
          completed: current_application.efl_completed,
        )
        @return_to = return_to_after_edit(default: candidate_interface_application_form_path)
      end

      def complete
        @component_instance = ChooseEflReviewComponent.call(english_proficiency)
        @section_complete_form = SectionCompleteForm.new(completion_params)
        @return_to = return_to_after_edit(default: candidate_interface_application_form_path)

        if @section_complete_form.save(current_application, :efl_completed)
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

    private

      def english_proficiency
        current_application.english_proficiency
      end

      def check_for_english_proficiency
        if english_proficiency.blank?
          redirect_to_efl_root
        end
      end

      def completion_params
        strip_whitespace params
          .require(:candidate_interface_section_complete_form)
          .permit(:completed)
      end
    end
  end
end
