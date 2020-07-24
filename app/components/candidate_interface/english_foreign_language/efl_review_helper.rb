module CandidateInterface
  module EnglishForeignLanguage
    module EflReviewHelper
      include Rails.application.routes.url_helpers

      def do_you_have_a_qualification_row(value:)
        {
          key: 'Do you have an English as a foreign language qualification?',
          value: value,
          action: 'Change whether or not you have a qualification',
          change_path: candidate_interface_english_foreign_language_edit_start_path,
        }
      end

      def type_of_qualification_row(name:)
        {
          key: 'Type of qualification',
          value: name,
          action: 'Change type of qualification',
          change_path: candidate_interface_english_foreign_language_type_path,
        }
      end
    end
  end
end
