require 'rails_helper'

RSpec.describe CandidateInterface::Reference::NameStep do
  include Rails.application.routes.url_helpers

  subject(:name_step) do
    described_class.new(
      referee_type:,
      name: 'Walter White',
      wizard:,
    )
  end

  let(:wizard) do
    CandidateInterface::ReferenceWizard.new(
      reference_process:,
      current_step: :reference_name,
      return_to_path:,
      application_choice:,
      reference:,
    )
  end
  let(:referee_type) { 'academic' }
  let(:return_to_path) { nil }
  let(:reference_process) { 'candidate-details' }
  let(:application_choice) { create(:application_choice) }
  let(:reference) { create(:reference) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(200) }

  describe '.permitted_params' do
    it 'returns the permitted params' do
      expect(described_class.permitted_params).to eq(%i[name referee_type])
    end
  end

  describe '#previous_step' do
    context 'when return_to_path is present' do
      let(:return_to_path) do
        candidate_interface_references_start_path(reference_process)
      end

      it 'returns the return_to_path' do
        expect(name_step.previous_step).to eq(return_to_path)
      end
    end

    context 'when return_to_path is not present' do
      it 'returns the candidate-details previous step path' do
        expect(name_step.previous_step).to eq(
          candidate_interface_references_type_path(
            reference_process,
            referee_type,
            reference.id,
            application_id: application_choice.id,
          ),
        )
      end
    end
  end

  describe '#next_step' do
    context 'when return_to_path is present' do
      let(:return_to_path) do
        candidate_interface_references_start_path(reference_process)
      end

      it 'returns the return_to_path' do
        expect(name_step.next_step).to eq(return_to_path)
      end
    end

    context 'when reference_process is accept-offer' do
      let(:reference_process) { 'accept-offer' }

      it 'returns the accept-offer next email path' do
        expect(name_step.next_step).to eq(
          candidate_interface_references_email_address_path(
            reference_process,
            reference,
            application_id: application_choice.id,
          ),
        )
      end
    end

    context 'when reference_process is not accept-offer' do
      it 'returns the references next email path' do
        expect(name_step.next_step).to eq(
          candidate_interface_references_email_address_path(
            reference_process,
            reference,
          ),
        )
      end
    end
  end
end
