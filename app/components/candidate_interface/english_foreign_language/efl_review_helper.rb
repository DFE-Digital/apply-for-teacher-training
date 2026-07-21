module CandidateInterface
  module EnglishForeignLanguage
    module EflReviewHelper
      def do_you_have_a_qualification_row(value:, return_to_application_review: false, editable: true)
        {
          key: 'Have you done an English as a foreign language assessment?',
          value:,
          html_attributes: {
            data: {
              qa: 'english-as-a-foreign-language',
            },
          },
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_english_foreign_language_edit_start_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'whether or not you have a qualification',
            }
          end
        end
      end

      def type_of_qualification_row(name:, return_to_application_review: false, editable: true)
        {
          key: 'Type of assessment',
          value: name,
          html_attributes: {
            data: {
              qa: 'english-as-a-foreign-language-type',
            },
          },
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_english_foreign_language_type_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'type of assessment',
            }
          end
        end
      end

      def return_to_params(return_to_application_review)
        { 'return-to' => 'application-review' } if return_to_application_review
      end
    end
  end
end
