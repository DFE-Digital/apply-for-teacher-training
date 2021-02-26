require 'rails_helper'

RSpec.describe CandidateInterface::LanguagesForm, type: :model do
  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(
        english_main_language: true,
        english_language_details: nil,
        other_language_details: 'I speak French',
      )
      languages_form = CandidateInterface::LanguagesForm.build_from_application(
        application_form,
      )

      expect(languages_form).to have_attributes(
        english_main_language: 'yes',
        english_language_details: nil,
        other_language_details: 'I speak French',
      )
    end

    it "initialises english_main_language to nil when it's nil in the application form" do
      application_form = ApplicationForm.new(english_main_language: nil)
      languages_form = CandidateInterface::LanguagesForm.build_from_application(
        application_form,
      )

      expect(languages_form).to have_attributes(english_main_language: nil)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      languages_form = CandidateInterface::LanguagesForm.new

      expect(languages_form.save(ApplicationForm.new)).to eq(false)
    end

    it 'saves the English language details only if English is not the main language' do
      form_data = {
        english_main_language: 'no',
        english_language_details: 'I have English qualifications',
        other_language_details: 'I also speak French',
      }
      application_form = FactoryBot.build(:application_form)
      languages_form = CandidateInterface::LanguagesForm.new(form_data)

      languages_form.save(application_form)

      expect(application_form.english_language_details).to eq 'I have English qualifications'
      expect(application_form.other_language_details).to eq nil
    end

    it 'saves the other language details only if English is the main language' do
      form_data = {
        english_main_language: 'yes',
        english_language_details: 'I have English qualifications',
        other_language_details: 'I also speak French',
      }
      application_form = FactoryBot.build(:application_form)
      languages_form = CandidateInterface::LanguagesForm.new(form_data)

      languages_form.save(application_form)

      expect(application_form.other_language_details).to eq 'I also speak French'
      expect(application_form.english_language_details).to eq nil
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:english_main_language) }

    okay_text = Faker::Lorem.sentence(word_count: 200)
    long_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(okay_text).for(:english_language_details) }
    it { is_expected.not_to allow_value(long_text).for(:english_language_details) }

    it { is_expected.to allow_value(okay_text).for(:other_language_details) }
    it { is_expected.not_to allow_value(long_text).for(:other_language_details) }
  end

  describe '#english_main_language?' do
    it 'returns true if "yes"' do
      languages_form = CandidateInterface::LanguagesForm.new(english_main_language: 'yes')

      expect(languages_form).to be_english_main_language
    end

    it 'returns false if "no"' do
      languages_form = CandidateInterface::LanguagesForm.new(english_main_language: 'no')

      expect(languages_form).not_to be_english_main_language
    end
  end
end
