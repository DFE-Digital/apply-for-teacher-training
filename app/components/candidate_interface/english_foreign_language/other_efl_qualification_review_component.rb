module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationReviewComponent < ApplicationComponent
      include EflReviewHelper

      attr_reader :other_qualification, :return_to_application_review, :editable

      def initialize(other_qualification, return_to_application_review: false, editable: true)
        @other_qualification = other_qualification
        @return_to_application_review = return_to_application_review
        @editable = editable
      end

      def ielts_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review:, editable:),
          type_of_qualification_row(name: other_qualification.name, return_to_application_review:, editable:),
          score_row,
          year_completed_row,
        ]
      end

    private

      def score_row
        {
          key: 'Score or grade',
          value: other_qualification.grade,
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_other_efl_qualification_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'score or grade',
            }
          end
        end
      end

      def year_completed_row
        {
          key: 'Year completed',
          value: other_qualification.award_year,
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_other_efl_qualification_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'year completed',
            }
          end
        end
      end
    end
  end
end
