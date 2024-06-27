require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RelationshipStep do
  include Rails.application.routes.url_helpers

  subject(:relationship_step) do
    described_class.new(
      relationship: 'family',
      wizard:,
    )
  end

  let(:wizard) do
    CandidateInterface::ReferenceWizard.new(
      reference_process:,
      current_step: :reference_email_address,
      return_to_path:,
      application_choice:,
      reference:,
    )
  end
  let(:return_to_path) { nil }
  let(:reference_process) { 'candidate-details' }
  let(:application_choice) { create(:application_choice) }
  let(:reference) { create(:reference) }

  it { is_expected.to validate_presence_of(:relationship) }
  it { is_expected.to validate_length_of(:relationship).is_at_most(500) }

  describe '.permitted_params' do
    it 'returns the permitted params' do
      expect(described_class.permitted_params).to eq([:relationship])
    end
  end

  describe '#previous_step' do
    context 'when return_to_path is present' do
      let(:return_to_path) do
        candidate_interface_references_start_path(reference_process)
      end

      it 'returns the return_to_path' do
        expect(relationship_step.previous_step).to eq(return_to_path)
      end
    end

    context 'when return_to_path is not present' do
      it 'returns the references email previous step' do
        expect(relationship_step.previous_step).to eq(
          candidate_interface_references_email_address_path(
            reference_process,
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
        expect(relationship_step.next_step).to eq(return_to_path)
      end
    end

    context 'when reference_process is candidate-details' do
      it 'returns the candidate-details next relationship path' do
        expect(relationship_step.next_step).to eq(
          candidate_interface_references_review_path(reference_process),
        )
      end
    end

    context 'when reference_process is accept-offer' do
      let(:reference_process) { 'accept-offer' }

      it 'returns the accept-offer next relationship path' do
        expect(relationship_step.next_step).to eq(
          candidate_interface_accept_offer_path(application_choice),
        )
      end
    end

    context 'when reference_process is request-reference' do
      let(:reference_process) { 'request-reference' }

      it 'returns the request-reference next relationship path' do
        expect(relationship_step.next_step).to eq(
          candidate_interface_new_references_review_path(
            reference_process,
            reference,
          ),
        )
      end
    end
  end
end
