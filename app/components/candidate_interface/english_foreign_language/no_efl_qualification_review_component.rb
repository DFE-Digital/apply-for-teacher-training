module CandidateInterface
  module EnglishForeignLanguage
    class NoEflQualificationReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :english_proficiency

      def initialize(english_proficiency)
        @english_proficiency = english_proficiency
      end

      def no_qualification_rows
        [
          do_you_have_a_qualification_row(value: summary),
        ]
      end

    private

      def summary
        if english_proficiency.qualification_not_needed?
          'No, English is not a foreign language to me'
        else
          tag.p('No, I do not have an English as a foreign language qualification', class: 'govuk-body') +
            tag.p(english_proficiency.no_qualification_details, class: 'govuk-body')
        end
      end
    end
  end
end
