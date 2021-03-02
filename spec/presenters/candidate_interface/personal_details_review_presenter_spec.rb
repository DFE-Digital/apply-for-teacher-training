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
  factory :languages_form, class: 'CandidateInterface::LanguagesForm' do
    english_main_language { %w[yes no].sample }
    english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
    other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
  end
end

FactoryBot.define do
  factory :right_to_work_form, class: 'CandidateInterface::RightToWorkOrStudyForm' do
    right_to_work_or_study { 'yes' }
    right_to_work_or_study_details { 'I have the right.' }
  end
end

RSpec.describe CandidateInterface::PersonalDetailsReviewPresenter do
  include Rails.application.routes.url_helpers

  let(:default_personal_details_form) { build(:personal_details_form) }
  let(:default_nationalities_form) { build(:nationalities_form) }
  let(:default_languages_form) { build(:languages_form) }
  let(:default_right_to_work_form) { build(:right_to_work_form) }
  let(:default_application_form) { build(:application_form) }

  def rows(
    personal_details_form: default_personal_details_form,
    nationalities_form: default_nationalities_form,
    languages_form: default_languages_form,
    right_to_work_form: default_right_to_work_form,
    application_form: default_application_form
  )
    CandidateInterface::PersonalDetailsReviewPresenter.new(
      personal_details_form: personal_details_form,
      nationalities_form: nationalities_form,
      languages_form: languages_form,
      right_to_work_form: right_to_work_form,
      application_form: application_form,
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

      expect(rows(personal_details_form: personal_details_form)).to include(
        row_for(:name, 'Max Caulfield', candidate_interface_edit_name_and_dob_path),
        row_for(:date_of_birth, '21 September 1995', candidate_interface_edit_name_and_dob_path),
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

      expect(rows(nationalities_form: nationalities_form)).to include(
        row_for(:nationality, 'British', candidate_interface_edit_nationalities_path),
      )
    end

    it 'includes a hash for dual nationalities' do
      nationalities_form = build(
        :nationalities_form,
        british: 'British',
        irish: nil,
        other_nationality1: 'Spanish',
      )

      expect(rows(nationalities_form: nationalities_form)).to include(
        row_for(:nationality, 'British and Spanish', candidate_interface_edit_nationalities_path),
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

      expect(rows(nationalities_form: nationalities_form)).to include(
        row_for(:nationality, 'British, French, German, and Spanish', candidate_interface_edit_nationalities_path),
      )
    end
  end

  context 'when the language rows should be hidden' do
    before { allow(LanguagesSectionPolicy).to receive(:hide?).and_return true }

    it 'does not show the language rows' do
      languages_form = build(
        :languages_form,
        english_main_language: 'Yes',
        english_language_details: '',
        other_language_details: 'Glossolalia',
      )

      row_data = rows(languages_form: languages_form)
      keys = row_data.map { |row| row[:key] }
      expect(keys).to match_array ['Name', 'Date of birth', 'Nationality', 'Immigration status']
    end
  end

  context 'when the candidate has selected they have the right to work' do
    it 'renders the right to work row' do
      nationalities_form = build(
        :nationalities_form,
        first_nationality: 'German',
      )
      right_to_work_form = build(
        :right_to_work_form,
        right_to_work_or_study: 'yes',
        right_to_work_or_study_details: 'I have the right.',
      )

      expect(rows(nationalities_form: nationalities_form, right_to_work_form: right_to_work_form)).to include(
        row_for(:right_to_work, 'I have the right to work or study in the UK<br> <p>I have the right.</p>', candidate_interface_edit_right_to_work_or_study_path),
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

      expect(rows(application_form: application_form, nationalities_form: nationalities_form, right_to_work_form: right_to_work_form)).not_to include(
        row_for(:right_to_work, "I have the right to work or study in the UK \b<br> <p>I have the right.</p>", candidate_interface_edit_right_to_work_or_study_path),
      )
    end
  end

  def row_for(key, value, path)
    {
      key: t("application_form.personal_details.#{key}.label"),
      value: value,
      action: t("application_form.personal_details.#{key}.change_action"),
      change_path: path,
    }
  end
end
