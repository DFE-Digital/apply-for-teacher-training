require 'rails_helper'

RSpec.describe Adviser::SignUp do
  include_context 'get into teaching api stubbed endpoints'

  before do
    availability_double = instance_double(Adviser::SignUpAvailability, available?: available, adviser_status_changed: nil)
    allow(Adviser::SignUpAvailability).to receive(:new).and_return(availability_double)
    allow(AdviserSignUpWorker).to receive(:perform_async)
  end

  let(:available) { true }
  let(:application_form) { create(:completed_application_form, :with_domestic_adviser_qualifications) }

  subject(:sign_up) do
    described_class.new(
      application_form,
      preferred_teaching_subject: preferred_teaching_subject&.value,
    )
  end

  describe 'validations' do
    let(:valid_subjects) { [preferred_teaching_subject.value] }

    it { is_expected.to validate_inclusion_of(:preferred_teaching_subject).in_array(valid_subjects) }
  end

  describe '#teaching_subjects' do
    it 'returns teaching subjects' do
      expect(sign_up.teaching_subjects).to contain_exactly(preferred_teaching_subject)
    end
  end

  describe '#save' do
    it 'returns true' do
      expect(sign_up.save).to be(true)
    end

    it 'enqueues an AdviserSignUpWorker job' do
      sign_up.save
      expect(AdviserSignUpWorker).to have_received(:perform_async).with(
        application_form.id,
        preferred_teaching_subject.id,
      )
    end

    it 'sets adviser_status to waiting_to_be_assigned' do
      expect { sign_up.save }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:waiting_to_be_assigned])
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
        expect { sign_up.save }.not_to change(application_form, :adviser_status)
      end
    end
  end
end
