require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceStore do
  subject(:store) { described_class.new(wizard) }

  let(:wizard) do
    CandidateInterface::ReferenceWizard.new(
      current_step: :reference_name,
      current_application: create(:application_form),
      reference:,
      step_params:,
    )
  end
  let(:reference) { create(:reference) }
  let(:step_params) do
    ActionController::Parameters.new(
      {
        reference_name: {
          name: 'Walter White',
          referee_type: 'professional',
        },
      },
    )
  end

  describe '#save' do
    context 'when reference is present' do
      it 'updates the current reference' do
        store.save

        expect(reference.name).to eq('Walter White')
        expect(reference.referee_type).to eq('professional')
      end
    end

    context 'when reference is not present' do
      let(:reference) { nil }

      it 'create a new reference' do
        expect { store.save }.to change(ApplicationReference, :count).by(1)

        reference = ApplicationReference.last
        expect(reference.name).to eq('Walter White')
        expect(reference.referee_type).to eq('professional')
      end
    end

    context 'when step is invalid' do
      let(:step_params) { nil }

      it 'returns false' do
        expect(store.save).to be(false)
      end
    end
  end
end
