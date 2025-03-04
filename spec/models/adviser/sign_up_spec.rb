require 'rails_helper'

RSpec.describe Adviser::SignUp do
  before do
    allow(Adviser::SignUpAvailability).to receive(:new).and_return(availability_double)
    allow(AdviserSignUpWorker).to receive(:perform_async)
  end

  let(:availability_double) { instance_double(Adviser::SignUpAvailability, available?: available, update_adviser_status: nil) }
  let(:available) { true }
  let(:application_form) { create(:completed_application_form, :with_domestic_adviser_qualifications) }

  let(:preferred_teaching_subject) { create(:adviser_teaching_subject) }

  subject(:sign_up) do
    described_class.new(
      application_form,
      preferred_teaching_subject_id: preferred_teaching_subject&.external_identifier,
    )
  end

  describe 'validations' do
    let(:valid_subjects) { create_list(:adviser_teaching_subject, 2).pluck(:external_identifier) }

    it { is_expected.to validate_inclusion_of(:preferred_teaching_subject_id).in_array(valid_subjects) }
  end

  describe '#save' do
    it 'returns true' do
      expect(sign_up.save).to be(true)
    end

    it 'enqueues an AdviserSignUpWorker job' do
      sign_up.save
      expect(AdviserSignUpWorker).to have_received(:perform_async).with(
        application_form.id,
        preferred_teaching_subject.external_identifier,
      )
    end

    it 'sets adviser_status to waiting_to_be_assigned' do
      sign_up.save
      status = ApplicationForm.adviser_statuses[:waiting_to_be_assigned]
      expect(availability_double).to have_received(:update_adviser_status).with(status)
    end

    context 'when not available' do
      let(:available) { false }

      it 'raises an error' do
        expect { sign_up.save }.to raise_error(described_class::AdviserSignUpUnavailableError)
      end
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
        expect(availability_double).not_to have_received(:update_adviser_status)
      end
    end
  end
end
