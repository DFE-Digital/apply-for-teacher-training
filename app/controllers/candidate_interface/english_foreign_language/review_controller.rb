module CandidateInterface
  module EnglishForeignLanguage
    class ReviewController < CandidateInterfaceController
      before_action :check_for_english_proficiency

      def show
        @component_instance = derive_component_instance(english_proficiency)
      end

      def complete
        current_application.update!(completion_params)
        redirect_to candidate_interface_application_form_path
      end

    private

      def english_proficiency
        current_application.english_proficiency
      end

      def check_for_english_proficiency
        if english_proficiency.blank?
          redirect_to candidate_interface_english_foreign_language_root_path
        end
      end

      def derive_component_instance(english_proficiency)
        qualification = english_proficiency.efl_qualification
        type = english_proficiency.efl_qualification_type

        case type
        when 'IeltsQualification'
          IeltsReviewComponent.new(qualification)
        when 'ToeflQualification'
          ToeflReviewComponent.new(qualification)
        end
      end

      def completion_params
        params
          .require(:application_form)
          .permit(:efl_completed)
      end
    end
  end
end
