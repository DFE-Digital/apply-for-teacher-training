require 'rails_helper'

RSpec.describe CandidateInterface::LanguagesForm, type: :model do
  let(:data) do
    {
      english_main_language: true,
      english_language_details: '',
      other_language_details: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  let(:form_data) do
    {
      english_main_language: data[:english_main_language] ? 'yes' : 'no',
      english_language_details: data[:english_language_details],
      other_language_details: data[:other_language_details],
    }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      languages_form = CandidateInterface::LanguagesForm.build_from_application(
        application_form,
      )

      expect(languages_form).to have_attributes(form_data)
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

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      languages_form = CandidateInterface::LanguagesForm.new(form_data)

      expect(languages_form.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end

    it 'saves the English language details only if English is not the main language' do
      application_form = FactoryBot.create(:application_form)
      data[:english_main_language] = false
      languages_form = CandidateInterface::LanguagesForm.new(form_data)

      languages_form.save(application_form)

      expect(application_form.english_language_details).to eq(form_data[:english_language_details])
      expect(application_form.other_language_details).to eq('')
    end

    it 'saves the other language details only if English is the main language' do
      application_form = FactoryBot.create(:application_form)
      data[:other_language_details] = Faker::Lorem.paragraph_by_chars(number: 200)
      languages_form = CandidateInterface::LanguagesForm.new(form_data)

      languages_form.save(application_form)

      expect(application_form.other_language_details).to eq(form_data[:other_language_details])
      expect(application_form.english_language_details).to eq('')
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
