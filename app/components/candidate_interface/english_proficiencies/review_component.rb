module CandidateInterface
  module EnglishProficiencies
    class ReviewComponent < ViewComponent::Base
      attr_reader :english_proficiencies

      def initialize(english_proficiencies)
        @english_proficiencies = english_proficiencies
      end

      def rows
        [
          {
            key: { text: 'Proving your level of English' },
            value: { text: english_proficiency_status },
            actions: [ { href: candidate_interface_english_proficiencies_edit_start_path, visually_hidden_text: 'level of english' }],
          },
        ].concat(no_qualification_details_rows)
         .concat(has_qualification_rows)
      end

    private

      def english_proficiency_status
        content_tag(:p, class: 'govuk-body') do
          simple_format(
            english_proficiencies.pluck(:qualification_status).map do |status|
              I18n.t("candidate_interface.english_proficiencies.review_component.qualification_status.#{status}")
            end.join("\n"),
          )
        end
      end

      def no_qualification_details_rows
        return [] if has_qualification_english_proficiency.present? || no_qualification_english_proficiency.blank?

        if no_qualification_english_proficiency.no_qualification_details.present?
          [
            {
              key: { text: 'Do you plan on taking an English as a foreign language assessment?' },
              value: { text: 'Yes' },
              actions: [
                {
                  href: candidate_interface_english_proficiencies_no_qualification_details_path(
                    no_qualification_english_proficiency,
                    ),
                  visually_hidden_text: 'plan to take an English as a foreign language assessment',
                }
              ],
            },
            {
              key: { text: 'Details' },
              value: { text: no_qualification_english_proficiency.no_qualification_details },
              actions: [
                {
                  href: candidate_interface_english_proficiencies_no_qualification_details_path(
                    no_qualification_english_proficiency,
                    ),
                  visually_hidden_text: 'plan to take an English as a foreign language assessment details',
                }
              ],
            },
          ]
        else
          [
            {
              key: { text: 'Do you plan on taking an English as a foreign language assessment?' },
              value: { text: 'No' },
              actions: [
                {
                  href: candidate_interface_english_proficiencies_no_qualification_details_path(
                    no_qualification_english_proficiency,
                    ),
                  visually_hidden_text: 'plan to take an English as a foreign language assessment',
                }
              ],
            },
          ]
        end
      end

      def has_qualification_rows
        return [] if has_qualification_english_proficiency.blank?

        case has_qualification_english_proficiency.efl_qualification_type
        when "IeltsQualification"
          ielts_rows
        when "ToeflQualification"
          toefl_rows
        else
          other_qualification_rows
        end
      end

      def ielts_rows
        [
          {
            key: { text: 'Type of assessment' },
            value: { text: 'IETLS' },
            actions: [
              {
                href: candidate_interface_english_proficiencies_type_path,
                visually_hidden_text: 'type of assessment',
              }
            ],
          },
          {
            key: { text: 'Test report form (TRF) number' },
            value: { text: english_proficiency_qualification.unique_reference_number },
            actions: [
              {
                href: candidate_interface_english_proficiencies_type_path,
                visually_hidden_text: 'test report form (TRF) number',
              }
            ],
          },
          {
            key: { text: 'Overall band score' },
            value: { text: english_proficiency_qualification.grade },
            actions: [
              {
                href: candidate_interface_english_proficiencies_type_path,
                visually_hidden_text: 'overall band score',
              }
            ],
          },
          {
            key: { text: 'Year completed' },
            value: { text: english_proficiency_qualification.award_year },
            actions: [
              {
                href: candidate_interface_english_proficiencies_type_path,
                visually_hidden_text: 'award year',
              }
            ],
          },
        ]
      end

      def no_qualification_english_proficiency
        @no_qualification_english_proficiency ||= english_proficiencies.where(
          qualification_status: %w[no_qualification degree_taught_in_english],
        ).last
      end

      def has_qualification_english_proficiency
        @has_qualification_english_proficiency ||= english_proficiencies.has_qualification.last
      end

      def english_proficiency_qualification
        @english_proficiency_qualification ||= has_qualification_english_proficiency.efl_qualification
      end
    end
  end
end

