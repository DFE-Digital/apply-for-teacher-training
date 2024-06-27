require 'rails_helper'

RSpec.describe CandidateInterface::Reference::TypeStep do
  include Rails.application.routes.url_helpers

  subject(:type_step) do
    described_class.new(
      referee_type:,
      wizard:,
    )
  end

  let(:wizard) do
    CandidateInterface::ReferenceWizard.new(
      reference_process:,
      current_step: :reference_type,
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

  it { is_expected.to validate_presence_of(:referee_type) }

  describe '.permitted_params' do
    it 'returns the permitted params' do
      expect(described_class.permitted_params).to eq([:referee_type])
    end
  end

  describe '#previous_step' do
    context 'when return_to_path is present' do
      let(:return_to_path) do
        candidate_interface_references_start_path(reference_process)
      end

      it 'returns the return_to_path' do
        expect(type_step.previous_step).to eq(return_to_path)
      end
    end

    context 'when reference_process is candidate-details' do
      it 'returns the candidate-details previous step path' do
        expect(type_step.previous_step).to eq(
          candidate_interface_references_start_path(reference_process),
        )
      end
    end

    context 'when reference_process is request-reference' do
      let(:reference_process) { 'request-reference' }

      it 'returns the request-reference previous step path' do
        expect(type_step.previous_step).to eq(
          candidate_interface_request_new_reference_path(reference_process),
        )
      end
    end

    context 'when reference_process is accept-offer' do
      let(:reference_process) { 'accept-offer' }

      it 'returns the accept-offer previous step path' do
        expect(type_step.previous_step).to eq(
          candidate_interface_accept_offer_path(application_choice),
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
        expect(type_step.next_step).to eq(return_to_path)
      end
    end

    context 'when reference_process is candidate-details' do
      it 'returns the candidate-details next step path' do
        expect(type_step.next_step).to eq(
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference.id,
          ),
        )
      end
    end

    context 'when reference_process is request-reference' do
      let(:reference_process) { 'request-reference' }

      it 'returns the request-reference next step path' do
        expect(type_step.next_step).to eq(
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference.id,
          ),
        )
      end
    end

    context 'when reference_process is accept-offer' do
      let(:reference_process) { 'accept-offer' }

      it 'returns the accept-offer next step path' do
        expect(type_step.next_step).to eq(
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference.id,
            application_id: application_choice.id,
          ),
        )
      end
    end
  end
end
