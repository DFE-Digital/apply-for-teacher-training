require 'rails_helper'

FactoryBot.define do
  factory :personal_details_form, class: CandidateInterface::PersonalDetailsForm do
    date_of_birth = Faker::Date.birthday

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    day { date_of_birth.day }
    month { date_of_birth.month }
    year { date_of_birth.year }
    first_nationality { NATIONALITIES.sample }
    second_nationality { NATIONALITIES.sample }
    english_main_language { %w[yes no].sample }
    english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
    other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
  end
end

RSpec.describe CandidateInterface::PersonalDetailsReviewPresenter do
  describe '#present' do
    it 'includes hashes for the name and date of birth' do
      personal_details_form = build(
        :personal_details_form,
        first_name: 'Max',
        last_name: 'Caulfield',
        day: 21,
        month: 9,
        year: 1995,
      )

      expect(present(personal_details_form)).to include(
        row_for(:name, 'Max Caulfield'),
        row_for(:date_of_birth, '21 September 1995'),
      )
    end

    context 'when presenting nationality' do
      it 'includes a hash for a single nationality' do
        personal_details_form = build(
          :personal_details_form,
          first_nationality: 'British',
          second_nationality: nil,
        )

        expect(present(personal_details_form)).to include(
          row_for(:nationality, 'British'),
        )
      end

      it 'includes a hash for dual nationalities' do
        personal_details_form = build(
          :personal_details_form,
          first_nationality: 'British',
          second_nationality: 'Spanish',
        )

        expect(present(personal_details_form)).to include(
          row_for(:nationality, 'British and Spanish'),
        )
      end
    end

    context 'when presenting English as the main language' do
      it 'includes a hash with "Yes"' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: '',
        )

        expect(present(personal_details_form)).to include(
          row_for(:english_main_language, 'Yes'),
        )
      end

      it 'excludes a hash for English language details if blank' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: '',
        )

        expect(present(personal_details_form)).not_to include(
          row_for(:english_main_language_details, ''),
        )
      end

      it 'excludes a hash for other language details if given' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'yes',
          english_language_details: '',
          other_language_details: 'Broken? Oh man, are you cereal?',
        )

        expect(present(personal_details_form)).not_to include(
          row_for(:other_language_details, 'Broken? Oh man, are you cereal?'),
        )
      end

      it 'includes a hash for English language details if given' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'yes',
          english_language_details: 'Mi nombre es Max.',
          other_language_details: '',
        )

        expect(present(personal_details_form)).to include(
          row_for(:english_main_language_details, 'Mi nombre es Max.'),
        )
      end
    end

    context 'when presenting English not as the main language' do
      it 'includes a hash with "No"' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'no',
          english_language_details: '',
          other_language_details: '',
        )

        expect(present(personal_details_form)).to include(
          row_for(:english_main_language, 'No'),
        )
      end

      it 'excludes a hash for other language details if blank' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'no',
          english_language_details: '',
          other_language_details: '',
        )

        expect(present(personal_details_form)).not_to include(
          row_for(:other_language_details, ''),
        )
      end

      it 'excludes a hash for English language details if given' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'no',
          english_language_details: 'Mi nombre es Max.',
          other_language_details: '',
        )

        expect(present(personal_details_form)).not_to include(
          row_for(:english_main_language_details, 'Mi nombre es Max.'),
        )
      end

      it 'includes a hash for other language details if given' do
        personal_details_form = build(
          :personal_details_form,
          english_main_language: 'no',
          english_language_details: '',
          other_language_details: 'Broken? Oh man, are you cereal?',
        )

        expect(present(personal_details_form)).to include(
          row_for(:other_language_details, 'Broken? Oh man, are you cereal?'),
        )
      end
    end
  end

  def present(form)
    CandidateInterface::PersonalDetailsReviewPresenter
      .new(form)
      .present
  end

  def row_for(key, value)
    {
      key: t("application_form.personal_details.#{key}.label"),
      value: value,
      action: t("application_form.personal_details.#{key}.change_action"),
    }
  end
end
