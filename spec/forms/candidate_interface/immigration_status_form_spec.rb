require 'rails_helper'

RSpec.describe CandidateInterface::ImmigrationStatusForm, type: :model do
  subject(:form) { described_class.new }

  let(:form_data) do
    {
      immigration_status: 'other',
      right_to_work_or_study_details: 'I have settled status',
    }
  end

  describe 'validations' do
    context 'when the immigration status is nil' do
      it 'validation keeps immigration_status as `nil`' do
        expect(form.valid?).to be false
        expect(form.immigration_status).to be_nil
      end
    end

    context 'when immigration_status is other' do
      before { form.immigration_status = 'other' }

      it { is_expected.to validate_presence_of(:right_to_work_or_study_details) }

      context 'right_to_work_or_study_details is 7 words or less' do
        before { form.right_to_work_or_study_details = 'This is less than seven words' }

        it 'is valid' do
          expect(form.valid?).to be true
        end
      end

      context 'right_to_work_or_study_details is exactly 7 words' do
        before { form.right_to_work_or_study_details = 'This sentence is exactly seven words long' }

        it 'is valid' do
          expect(form.valid?).to be true
        end
      end

      context 'right_to_work_or_study_details is more than 7 words' do
        before { form.right_to_work_or_study_details = 'This sentence has more than seven words in it' }

        it 'is not valid' do
          expect(form.valid?).to be false
          expect(form.errors[:right_to_work_or_study_details]).to include('Must be 7 words or less')
        end
      end
    end

    context 'when immigration_status is NOT other' do
      before { form.immigration_status = 'eu_settled' }

      it { is_expected.not_to validate_presence_of(:right_to_work_or_study_details) }
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(form_data)
      form = described_class.build_from_application(application_form)
      expect(form).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      form = described_class.new

      expect(form.save(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      form = described_class.new(form_data)

      expect(form.save(application_form)).to be(true)
      expect(application_form.immigration_status).to eq('other')
      expect(application_form.right_to_work_or_study_details).to eq('I have settled status')
    end

    it 'does not reset attributes' do
      application_data = {
        right_to_work_or_study: 'yes',
        immigration_status: 'other',
        right_to_work_or_study_details: 'I have permanent residence',
      }
      application_form = create(:application_form, application_data)
      form = described_class.new(form_data)

      expect(form.save(application_form)).to be(true)
      expect(application_form.reload.right_to_work_or_study).to eq('yes')
      expect(application_form.immigration_status).to eq('other')
      expect(application_form.right_to_work_or_study_details).to eq('I have settled status')
    end
  end
end
