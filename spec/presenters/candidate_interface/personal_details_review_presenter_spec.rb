require 'rails_helper'

FactoryBot.define do
  factory :personal_details_form, class: 'CandidateInterface::PersonalDetailsForm' do
    date_of_birth = Faker::Date.birthday

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    day { date_of_birth.day }
    month { date_of_birth.month }
    year { date_of_birth.year }
  end
end

FactoryBot.define do
  factory :nationalities_form, class: 'CandidateInterface::NationalitiesForm' do
    first_nationality { NATIONALITY_DEMONYMS.sample }
    second_nationality { NATIONALITY_DEMONYMS.sample }
  end
end

FactoryBot.define do
  factory :right_to_work_form, class: 'CandidateInterface::ImmigrationRightToWorkForm' do
    right_to_work_or_study { 'yes' }
    right_to_work_or_study_details { 'I have the right.' }
  end
end

RSpec.describe CandidateInterface::PersonalDetailsReviewPresenter, :mid_cycle do
  include Rails.application.routes.url_helpers

  let(:default_personal_details_form) { build(:personal_details_form) }
  let(:default_nationalities_form) { build(:nationalities_form) }
  let(:default_languages_form) { build(:languages_form) }
  let(:default_right_to_work_form) { build(:right_to_work_form) }
  let(:default_application_form) { build(:application_form) }

  def rows(
    personal_details_form: default_personal_details_form,
    nationalities_form: default_nationalities_form,
    right_to_work_form: default_right_to_work_form,
    application_form: default_application_form
  )
    CandidateInterface::PersonalDetailsReviewPresenter.new(
      personal_details_form:,
      nationalities_form:,
      right_to_work_form:,
      application_form:,
      return_to_application_review: true,
    ).rows
  end

  context 'when presenting personal details' do
    it 'includes hashes for the name and date of birth' do
      personal_details_form = build(
        :personal_details_form,
        first_name: 'Max',
        last_name: 'Caulfield',
        day: 21,
        month: 9,
        year: 1995,
      )

      expect(rows(personal_details_form:)).to include(
        row_for(
          :name,
          'Max Caulfield',
          candidate_interface_edit_name_and_dob_path('return-to' => 'application-review'),
          'personal-details-name',
        ),
        row_for(
          :date_of_birth,
          '21 September 1995',
          candidate_interface_edit_name_and_dob_path('return-to' => 'application-review'),
          'personal-details-dob',
        ),
      )
    end

    it 'returns nil when date of birth is not present' do
      personal_details_form = build(
        :personal_details_form,
        first_name: 'Max',
        last_name: 'Caulfield',
        day: nil,
        month: nil,
        year: nil,
      )

      expect(rows(personal_details_form:)).to include(
        row_for(
          :date_of_birth,
          nil,
          candidate_interface_edit_name_and_dob_path('return-to' => 'application-review'),
          'personal-details-dob',
        ),
      )
    end
  end

  context 'when presenting nationality' do
    it 'includes a hash for a single nationality' do
      nationalities_form = build(
        :nationalities_form,
        british: 'British',
        irish: nil,
      )

      expect(rows(nationalities_form:)).to include(
        row_for(
          :nationality,
          'British',
          candidate_interface_edit_nationalities_path('return-to' => 'application-review'),
          'personal-details-nationality',
        ),
      )
    end

    it 'includes a hash for dual nationalities' do
      nationalities_form = build(
        :nationalities_form,
        british: 'British',
        irish: nil,
        other_nationality1: 'Spanish',
      )

      expect(rows(nationalities_form:)).to include(
        row_for(
          :nationality,
          'British and Spanish',
          candidate_interface_edit_nationalities_path('return-to' => 'application-review'),
          'personal-details-nationality',
        ),
      )
    end

    it 'includes a hash with up to 5 nationalities' do
      nationalities_form = build(
        :nationalities_form,
        british: 'British',
        irish: nil,
        other_nationality1: 'French',
        other_nationality2: 'German',
        other_nationality3: 'Spanish',
      )

      expect(rows(nationalities_form:)).to include(
        row_for(
          :nationality,
          'British, French, German, and Spanish',
          candidate_interface_edit_nationalities_path('return-to' => 'application-review'),
          'personal-details-nationality',
        ),
      )
    end
  end

  context 'when the candidate has selected they have the right to work or study' do
    let(:default_application_form) { build(:application_form) }

    it 'renders the right to work row' do
      nationalities_form = build(
        :nationalities_form,
        first_nationality: 'German',
      )

      application_form = build(
        :application_form,
        right_to_work_or_study: 'yes',
        immigration_status: 'other',
        right_to_work_or_study_details: 'I have permanent residence',
      )

      rows = rows(nationalities_form:, application_form:)

      expect(rows).to include(
        row_for(
          :immigration_right_to_work,
          'Yes',
          candidate_interface_edit_immigration_right_to_work_path('return-to' => 'application-review'),
          'personal_details_immigration_right_to_work',
        ),
      )
      expect(rows).to include(
        row_for(
          :immigration_status,
          'I have permanent residence',
          candidate_interface_edit_immigration_status_path('return-to' => 'application-review'),
          'personal_details_immigration_status',
        ),
      )
    end
  end

  context 'when the candidate has selected they do not have the right to work or study in 2022' do
    let(:default_application_form) { build(:application_form, recruitment_cycle_year: 2022) }

    it 'renders the right to work row' do
      nationalities_form = build(
        :nationalities_form,
        first_nationality: 'Indian',
      )

      application_form = build(
        :application_form,
        recruitment_cycle_year: 2022,
        right_to_work_or_study: 'no',
      )

      rows = rows(nationalities_form:, application_form:)

      expect(rows).to include(
        row_for(
          :immigration_right_to_work,
          'Not yet',
          candidate_interface_edit_immigration_right_to_work_path('return-to' => 'application-review'),
          'personal_details_immigration_right_to_work',
        ),
      )
    end
  end

  context 'when the candidate is British or Irish' do
    it 'does not render the right to work row' do
      nationalities_form = build(
        :nationalities_form,
        first_nationality: 'British',
        second_nationality: 'Albanian',
      )
      right_to_work_form = build(
        :right_to_work_form,
        right_to_work_or_study: 'yes',
        right_to_work_or_study_details: 'I have the right.',
      )
      application_form = build(
        :application_form,
        first_nationality: 'Albanian',
        second_nationality: 'British',
      )

      expect(rows(application_form:, nationalities_form:, right_to_work_form:)).not_to include(
        row_for(
          :immigration_right_to_work,
          'Yes',
          candidate_interface_edit_immigration_right_to_work_path('return-to' => 'application-review'),
          'personal_details_immigration_right_to_work',
        ),
      )
    end
  end

  def row_for(key, value, path, data_qa)
    {
      key: t("application_form.personal_details.#{key}.label"),
      value:,
      action: {
        href: path,
        visually_hidden_text: t("application_form.personal_details.#{key}.change_action"),
      },
      html_attributes: {
        data: {
          qa: data_qa,
        },
      },
    }
  end
end
