require 'rails_helper'

RSpec.describe CandidateInterface::Reference::EmailAddressStep do
  include Rails.application.routes.url_helpers

  subject(:email_step) do
    described_class.new(
      email_address: 'iamthedanger@mail.com',
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

  it { is_expected.to validate_presence_of(:email_address) }

  one_hundred_character_email = "#{SecureRandom.hex(44)}@example.com"
  one_hundred_and_one_character_email = "#{SecureRandom.hex(45)}@example.com"

  it { is_expected.to allow_value(one_hundred_character_email).for(:email_address) }
  it { is_expected.not_to allow_value(one_hundred_and_one_character_email).for(:email_address) }

  describe '.permitted_params' do
    it 'returns the permitted params' do
      expect(described_class.permitted_params).to eq([:email_address])
    end
  end

  describe '#previous_step' do
    context 'when return_to_path is present' do
      let(:return_to_path) do
        candidate_interface_references_start_path(reference_process)
      end

      it 'returns the return_to_path' do
        expect(email_step.previous_step).to eq(return_to_path)
      end
    end

    context 'when return_to_path is not present' do
      it 'returns the references name previous step' do
        expect(email_step.previous_step).to eq(
          candidate_interface_references_name_path(
            reference_process,
            reference.referee_type.dasherize,
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
        expect(email_step.next_step).to eq(return_to_path)
      end
    end

    context 'when reference_process is accept-offer' do
      let(:reference_process) { 'accept-offer' }

      it 'returns the accept-offer next relationship path' do
        expect(email_step.next_step).to eq(
          candidate_interface_references_relationship_path(
            reference_process,
            reference.id,
            application_id: application_choice.id,
          ),
        )
      end
    end

    context 'when reference_process is not accept-offer' do
      it 'returns the references next relationship path' do
        expect(email_step.next_step).to eq(
          candidate_interface_references_relationship_path(
            reference_process,
            reference.id,
          ),
        )
      end
    end
  end
end
