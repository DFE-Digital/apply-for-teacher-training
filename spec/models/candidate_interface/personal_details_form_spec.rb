require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsForm, type: :model do
  let(:data) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      date_of_birth: Faker::Date.birthday,
      first_nationality: NATIONALITY_DEMONYMS.sample,
      second_nationality: NATIONALITY_DEMONYMS.sample,
      english_main_language: true,
      english_language_details: '',
      other_language_details: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  let(:form_data) do
    {
      first_name: data[:first_name],
      last_name: data[:last_name],
      day: data[:date_of_birth].day,
      month: data[:date_of_birth].month,
      year: data[:date_of_birth].year,
      first_nationality: data[:first_nationality],
      second_nationality: data[:second_nationality],
      english_main_language: data[:english_main_language] ? 'yes' : 'no',
      english_language_details: data[:english_language_details],
      other_language_details: data[:other_language_details],
    }
  end

  describe '#name' do
    it 'concatenates the first name and last name' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      personal_details = CandidateInterface::PersonalDetailsForm.build_from_application(
        application_form,
      )

      expect(personal_details).to have_attributes(form_data)
    end

    it "initialises english_main_language to nil when it's nil in the application form" do
      application_form = ApplicationForm.new(english_main_language: nil)
      personal_details = CandidateInterface::PersonalDetailsForm.build_from_application(
        application_form,
      )

      expect(personal_details).to have_attributes(english_main_language: nil)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      personal_details = CandidateInterface::PersonalDetailsForm.new

      expect(personal_details.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      personal_details = CandidateInterface::PersonalDetailsForm.new(form_data)

      expect(personal_details.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end

    it 'saves the English language details only if English is not the main language' do
      application_form = FactoryBot.create(:application_form)
      data[:english_main_language] = false
      personal_details = CandidateInterface::PersonalDetailsForm.new(form_data)

      personal_details.save(application_form)

      expect(application_form.english_language_details).to eq(form_data[:english_language_details])
      expect(application_form.other_language_details).to eq('')
    end

    it 'saves the other language details only if English is the main language' do
      application_form = FactoryBot.create(:application_form)
      data[:other_language_details] = Faker::Lorem.paragraph_by_chars(number: 200)
      personal_details = CandidateInterface::PersonalDetailsForm.new(form_data)

      personal_details.save(application_form)

      expect(application_form.other_language_details).to eq(form_data[:other_language_details])
      expect(application_form.english_language_details).to eq('')
    end
  end

  describe '#date_of_birth' do
    it 'return a nil for nil day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: nil, month: nil, year: nil)

      expect(personal_details.date_of_birth.day).to be_nil
      expect(personal_details.date_of_birth.month).to be_nil
      expect(personal_details.date_of_birth.year).to be_nil
    end

    it 'can return an invalid date object for invalid day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: 99, month: 99, year: 99)

      expect(personal_details.date_of_birth.day).to eq(99)
      expect(personal_details.date_of_birth.month).to eq(99)
      expect(personal_details.date_of_birth.year).to eq(99)
    end

    it 'returns a date for a valid day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: '2', month: '8', year: '1990')

      expect(personal_details.date_of_birth).to eq(Date.new(1990, 8, 2))
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:first_nationality) }
    it { is_expected.to validate_presence_of(:english_main_language) }

    it { is_expected.to validate_length_of(:first_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(60) }

    it 'validates nationalities against the NATIONALITY_DEMONYMS list' do
      details_with_invalid_nationality = CandidateInterface::PersonalDetailsForm.new(
        first_nationality: 'Tralfamadorian',
        second_nationality: 'Czechoslovakian',
      )

      details_with_valid_nationality = CandidateInterface::PersonalDetailsForm.new(
        first_nationality: NATIONALITY_DEMONYMS.sample,
        second_nationality: NATIONALITY_DEMONYMS.sample,
      )

      details_with_valid_nationality.validate
      details_with_invalid_nationality.validate

      expect(details_with_valid_nationality.errors.keys).not_to include :first_nationality
      expect(details_with_valid_nationality.errors.keys).not_to include :second_nationality

      expect(details_with_invalid_nationality.errors.keys).to include :first_nationality
      expect(details_with_invalid_nationality.errors.keys).to include :second_nationality
    end

    okay_text = Faker::Lorem.sentence(word_count: 200)
    long_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(okay_text).for(:english_language_details) }
    it { is_expected.not_to allow_value(long_text).for(:english_language_details) }

    it { is_expected.to allow_value(okay_text).for(:other_language_details) }
    it { is_expected.not_to allow_value(long_text).for(:other_language_details) }

    describe 'date of birth' do
      it 'is invalid if not well-formed' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '99', month: '99', year: '99',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a date of birth in the correct format'],
        )
      end

      it 'is invalid if the date is in the future' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '2', month: '8', year: '2999',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a date of birth that is in the past, for example 31 3 1980'],
        )
      end
    end
  end

  describe '#english_main_language?' do
    it 'returns true if "yes"' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(english_main_language: 'yes')

      expect(personal_details).to be_english_main_language
    end

    it 'returns false if "no"' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(english_main_language: 'no')

      expect(personal_details).not_to be_english_main_language
    end
  end
end
