module CandidateInterface
  module EnglishForeignLanguage
    class ReviewController < CandidateInterfaceController
      before_action :check_for_english_language_proficiency

      def show
        @english_language_proficiency = current_application.english_language_proficiency
        @component_instance = derive_component_instance(@english_language_proficiency)
      end

    private

      def check_for_english_language_proficiency
        if current_application.english_language_proficiency.blank?
          redirect_to candidate_interface_english_foreign_language_root_path
        end
      end

      def derive_component_instance(english_language_proficiency)
        case english_language_proficiency.efl_qualification_type
        when 'IeltsQualification'
          IeltsReviewComponent.new(english_language_proficiency.efl_qualification)
        end
      end
    end
  end
end
