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

RSpec.describe CandidateInterface::PersonalDetailsReviewPresenter do
  let(:personal_details_form) { build(:personal_details_form) }
  let(:nationalities_form) { build(:nationalities_form) }
  let(:languages_form) { build(:languages_form) }

  context 'when personal details are editable' do
    it 'includes hashes for the name and date of birth' do
      personal_details_form = build(
        :personal_details_form,
        first_name: 'Max',
        last_name: 'Caulfield',
        day: 21,
        month: 9,
        year: 1995,
      )

      expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
        row_for(:name, 'Max Caulfield'),
        row_for(:date_of_birth, '21 September 1995'),
      )
    end

    context 'when presenting nationality' do
      it 'includes a hash for a single nationality' do
        nationalities_form = build(
          :nationalities_form,
          first_nationality: 'British',
          second_nationality: nil,
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
          row_for(:nationality, 'British'),
        )
      end

      it 'includes a hash for dual nationalities' do
        nationalities_form = build(
          :nationalities_form,
          first_nationality: 'British',
          second_nationality: 'Spanish',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
          row_for(:nationality, 'British and Spanish'),
        )
      end
    end

    context 'when presenting English as the main language' do
      it 'includes a hash with "Yes"' do
        languages_form = build(
          :languages_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: '',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
          row_for(:english_main_language, 'Yes'),
        )
      end

      it 'excludes a hash for English language details if blank' do
        languages_form = build(
          :languages_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: '',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).not_to include(
          row_for(:other_language_details, ''),
        )
      end

      it 'excludes a hash for other language details if given' do
        languages_form = build(
          :languages_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: 'Broken? Oh man, are you cereal?',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).not_to include(
          row_for(:english_language_details, 'Broken? Oh man, are you cereal?'),
        )
      end

      it 'includes a hash for English language details if given' do
        languages_form = build(
          :languages_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: 'I speak French',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
          row_for(:other_language_details, 'I speak French'),
        )
      end
    end

    context 'when presenting English not as the main language' do
      it 'includes a hash with "No"' do
        languages_form = build(
          :languages_form,
          english_main_language: 'no',
          english_language_details: '',
          other_language_details: '',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
          row_for(:english_main_language, 'No'),
        )
      end

      it 'excludes a hash for other language details if blank' do
        languages_form = build(
          :languages_form,
          english_main_language: 'no',
          english_language_details: '',
          other_language_details: '',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).not_to include(
          row_for(:english_language_details, ''),
        )
      end

      it 'excludes a hash for English language details if given' do
        languages_form = build(
          :languages_form,
          english_main_language: 'no',
          english_language_details: 'Mi nombre es Max.',
          other_language_details: '',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).not_to include(
          row_for(:other_language_details, 'Mi nombre es Max.'),
        )
      end

      it 'includes a hash for other language details if given' do
        languages_form = build(
          :languages_form,
          english_main_language: 'no',
          english_language_details: 'Broken? Oh man, are you cereal?',
          other_language_details: '',
        )

        expect(rows(personal_details_form, nationalities_form, languages_form)).to include(
          row_for(:english_language_details, 'Broken? Oh man, are you cereal?'),
        )
      end
    end
  end

  def rows(personal_details_form, nationalities_form, languages_form)
    CandidateInterface::PersonalDetailsReviewPresenter
      .new(personal_details_form: personal_details_form, nationalities_form: nationalities_form, languages_form: languages_form)
      .rows
  end

  def row_for(key, value)
    {
      key: t("application_form.personal_details.#{key}.label"),
      value: value,
      action: t("application_form.personal_details.#{key}.change_action"),
      change_path: Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path,
    }
  end
end
