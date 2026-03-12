module CandidateInterface
  module EnglishProficiencies
    class ReviewComponent < ViewComponent::Base
      attr_reader :english_proficiency

      def initialize(english_proficiency)
        @english_proficiency = english_proficiency
      end

      def rows
        [
          {
            key: { text: 'Proving your level of English' },
            value: { text: english_proficiency_status },
            actions: [{ href: candidate_interface_english_proficiencies_edit_start_path, visually_hidden_text: 'level of english' }],
          },
        ].concat(no_qualification_details_rows)
         .concat(qualification_rows)
      end

    private

      def english_proficiency_status
        content_tag(:p, class: 'govuk-body') do
          simple_format(
            english_proficiency.qualification_statuses.map do |status|
              I18n.t("candidate_interface.english_proficiencies.review_component.qualification_status.#{status}")
            end.join("\n"),
          )
        end
      end

      def no_qualification_details_rows
        return [] unless (!english_proficiency.has_qualification &&
                         english_proficiency.degree_taught_in_english) || english_proficiency.no_qualification

        if english_proficiency.no_qualification_details.present?
          [
            {
              key: { text: 'Do you plan on taking an English as a foreign language assessment?' },
              value: { text: 'Yes' },
              actions: [
                {
                  href: candidate_interface_english_proficiencies_no_qualification_details_path(
                    english_proficiency,
                    return_to: 'review',
                  ),
                  visually_hidden_text: 'plan to take an English as a foreign language assessment',
                },
              ],
            },
            {
              key: { text: 'Details' },
              value: { text: english_proficiency.no_qualification_details },
              actions: [
                {
                  href: candidate_interface_english_proficiencies_no_qualification_details_path(
                    english_proficiency,
                    return_to: 'review',
                  ),
                  visually_hidden_text: 'plan to take an English as a foreign language assessment details',
                },
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
                    english_proficiency,
                    return_to: 'review',
                  ),
                  visually_hidden_text: 'plan to take an English as a foreign language assessment',
                },
              ],
            },
          ]
        end
      end

      def qualification_rows
        return [] if english_proficiency_qualification.blank?

        case english_proficiency.efl_qualification_type
        when 'IeltsQualification'
          ielts_rows
        when 'ToeflQualification'
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
                href: candidate_interface_english_proficiencies_type_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'type of assessment',
              },
            ],
          },
          {
            key: { text: 'Test report form (TRF) number' },
            value: { text: english_proficiency_qualification.unique_reference_number },
            actions: [
              {
                href: candidate_interface_english_proficiencies_ielts_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'test report form (TRF) number',
              },
            ],
          },
          {
            key: { text: 'Overall band score' },
            value: { text: english_proficiency_qualification.grade },
            actions: [
              {
                href: candidate_interface_english_proficiencies_ielts_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'overall band score',
              },
            ],
          },
          {
            key: { text: 'Year completed' },
            value: { text: english_proficiency_qualification.award_year },
            actions: [
              {
                href: candidate_interface_english_proficiencies_ielts_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'award year',
              },
            ],
          },
        ]
      end

      def toefl_rows
        [
          {
            key: { text: 'Type of assessment' },
            value: { text: 'TOEFL' },
            actions: [
              {
                href: candidate_interface_english_proficiencies_type_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'type of assessment',
              },
            ],
          },
          {
            key: { text: 'TOEFL registration number' },
            value: { text: english_proficiency_qualification.registration_number },
            actions: [
              {
                href: candidate_interface_english_proficiencies_toefl_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'registration number',
              },
            ],
          },
          {
            key: { text: 'Year completed' },
            value: { text: english_proficiency_qualification.award_year },
            actions: [
              {
                href: candidate_interface_english_proficiencies_toefl_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'year completed',
              },
            ],
          },
          {
            key: { text: 'Total score' },
            value: { text: english_proficiency_qualification.total_score },
            actions: [
              {
                href: candidate_interface_english_proficiencies_toefl_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'total score',
              },
            ],
          },
        ]
      end

      def other_qualification_rows
        [
          {
            key: { text: 'Type of assessment' },
            value: { text: english_proficiency_qualification.name },
            actions: [
              {
                href: candidate_interface_english_proficiencies_type_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'type of assessment',
              },
            ],
          },
          {
            key: { text: 'Assessment name' },
            value: { text: english_proficiency_qualification.name },
            actions: [
              {
                href: candidate_interface_english_proficiencies_other_efl_qualification_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'assessment name',
              },
            ],
          },
          {
            key: { text: 'Score or grade' },
            value: { text: english_proficiency_qualification.grade },
            actions: [
              {
                href: candidate_interface_english_proficiencies_other_efl_qualification_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'score or grade',
              },
            ],
          },
          {
            key: { text: 'Year completed' },
            value: { text: english_proficiency_qualification.award_year },
            actions: [
              {
                href: candidate_interface_english_proficiencies_other_efl_qualification_path(
                  english_proficiency,
                  return_to: 'review',
                ),
                visually_hidden_text: 'year completed',
              },
            ],
          },
        ]
      end

      def english_proficiency_qualification
        @english_proficiency_qualification ||= english_proficiency.efl_qualification
      end
    end
  end
end
