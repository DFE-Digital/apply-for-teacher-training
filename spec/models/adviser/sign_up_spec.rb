require 'rails_helper'

RSpec.describe Adviser::SignUp do
  before do
    allow(AdviserSignUpWorker).to receive(:perform_async)
  end

  let(:application_form) { create(:completed_application_form, :with_domestic_adviser_qualifications) }

  let(:preferred_teaching_subject) { create(:adviser_teaching_subject) }

  subject(:sign_up) do
    described_class.new(
      application_form:,
      preferred_teaching_subject_id: preferred_teaching_subject&.external_identifier,
    )
  end

  describe 'validations' do
    let(:valid_subjects) { create_list(:adviser_teaching_subject, 2).pluck(:external_identifier) }

    it { is_expected.to validate_inclusion_of(:preferred_teaching_subject_id).in_array(valid_subjects) }

    it 'is invalid when the application_form is not eligible for an adviser' do
      allow(application_form).to receive(:eligible_and_unassigned_a_teaching_training_adviser?).and_return(false)

      expect(sign_up).not_to be_valid
      expect(sign_up.errors.messages[:application_form]).to include('You are not eligible for a Teacher Training Adviser')
    end
  end

  describe '#save' do
    it 'returns true' do
      expect(sign_up.save).to be(true)
    end

    it 'creates a new Adviser::SignUpRequest' do
      expect {
        sign_up.save
      }.to change(Adviser::SignUpRequest, :count).from(0).to(1)
    end

    it 'enqueues an AdviserSignUpWorker job' do
      sign_up.save
      expect(AdviserSignUpWorker).to have_received(:perform_async)
    end

    it 'sets adviser_status to waiting_to_be_assigned' do
      sign_up.save

      expect(application_form.reload).to be_adviser_status_waiting_to_be_assigned
    end

    context 'when invalid' do
      let(:preferred_teaching_subject) { nil }

      it 'returns false' do
        expect(sign_up.save).to be(false)
      end

      it 'does not enqueue a AdviserSignUpWorker job' do
        sign_up.save

        expect(AdviserSignUpWorker).not_to have_received(:perform_async)
      end

      it 'does not change adviser_status' do
        sign_up.save

        expect(application_form.reload).to be_adviser_status_unassigned
      end
    end
  end
end
