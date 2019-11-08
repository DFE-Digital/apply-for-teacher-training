require 'rails_helper'

RSpec.describe CandidateInterface::TrainingWithADisabilityForm, type: :model do
  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      data = {
        disclose_disability: true,
        disability_disclosure: 'I have difficulty climbing stairs'
      }
      application_form = build_stubbed(:application_form, data)
      disability_form = CandidateInterface::TrainingWithADisabilityForm.build_from_application(application_form)

      expect(disability_form).to have_attributes(data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      disability_form = CandidateInterface::TrainingWithADisabilityForm.new

      expect(disability_form.save(ApplicationForm.new)).to eq(false)
    end

    context 'when valid' do
      let(:form_data) do
        {
          disclose_disability: true,
          disability_disclosure: 'I have a hearing impairment'
        }
      end
      let(:application_form) { build(:application_form) }
      let(:disability_form) do
        CandidateInterface::TrainingWithADisabilityForm.new(form_data)
      end

      it 'updates the provided ApplicationForm' do
        expect(disability_form.save(application_form)).to eq(true)
        expect(application_form).to have_attributes(form_data)
      end

      context 'when the user selects No to the disclose_disability question' do
        let(:form_data) do
          {
            disclose_disability: false,
            disability_disclosure: 'I have a hearing impairment'
          }
        end
        before do
          allow(application_form).to receive(:update!).and_return true
        end

        it 'nulls-out the existing disability_disclosure' do
          disability_form.save(application_form)

          expect(application_form).to have_received(:update!).with({
            disability_disclosure: nil,
            disclose_disability: false
          })
        end
      end
    end
  end


  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:disclose_disability).in_array([true, false]) }
  end
end
