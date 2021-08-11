module CandidateInterface
  module EnglishForeignLanguage
    class NoEflQualificationReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :english_proficiency, :return_to_application_review

      def initialize(english_proficiency, return_to_application_review: false)
        @english_proficiency = english_proficiency
        @return_to_application_review = return_to_application_review
      end

      def no_qualification_rows
        [
          do_you_have_a_qualification_row(value: summary, return_to_application_review: return_to_application_review, return_to_application_review: return_to_application_review),
        ]
      end

    private

      def summary
        if english_proficiency.qualification_not_needed?
          'No, English is not a foreign language to me'
        else
          tag.p('No, I have not done an English as a foreign language assessment', class: 'govuk-body') +
            tag.p(english_proficiency.no_qualification_details, class: 'govuk-body')
        end
      end
    end
  end
end
