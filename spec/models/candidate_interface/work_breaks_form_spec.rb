require 'rails_helper'

RSpec.describe CandidateInterface::WorkBreaksForm, type: :model do
  let(:data) do
    {
      work_history_breaks: Faker::Lorem.paragraph_by_chars(number: 300),
    }
  end

  let(:form_data) do
    {
      work_history_breaks: data[:work_history_breaks],
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:work_history_breaks) }

    okay_text = Faker::Lorem.sentence(word_count: 400)
    long_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(okay_text).for(:work_history_breaks) }
    it { is_expected.not_to allow_value(long_text).for(:work_history_breaks) }
  end

  describe '#save' do
    it 'returns false if not valid' do
      work_breaks_form = CandidateInterface::WorkBreaksForm.new

      expect(work_breaks_form.save(ApplicationForm.new)).to eq(false)
    end

    it 'creates a new work experience if valid' do
      application_form = FactoryBot.create(:application_form)
      work_breaks_form = CandidateInterface::WorkBreaksForm.new(form_data)

      work_breaks_form.save(application_form)
      expect(application_form.reload).to have_attributes(data)
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided application form' do
      application_form = ApplicationForm.new(data)
      work_breaks_form = CandidateInterface::WorkBreaksForm.build_from_application(
        application_form,
      )

      expect(work_breaks_form).to have_attributes(form_data)
    end
  end
end
