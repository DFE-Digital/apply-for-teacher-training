module CandidateInterface
  module EnglishForeignLanguage
    class ReviewController < CandidateInterfaceController
      def show
        @english_language_proficiency = current_application.english_language_proficiency
      end
    end
  end
end
