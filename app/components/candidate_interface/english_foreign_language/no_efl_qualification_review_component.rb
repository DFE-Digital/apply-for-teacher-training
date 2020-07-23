module CandidateInterface
  module EnglishForeignLanguage
    class NoEflQualificationReviewComponent < ViewComponent::Base
      include Rails.application.routes.url_helpers

      attr_reader :english_proficiency

      def initialize(english_proficiency)
        @english_proficiency = english_proficiency
      end

      def no_qualification_rows
        [
          {
            key: 'Do you have an English as a foreign language qualification?',
            value: summary,
            action: 'Change whether or not you have a qualification',
            change_path: candidate_interface_english_foreign_language_edit_start_path,
          },
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
