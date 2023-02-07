require 'rails_helper'

RSpec.describe Adviser::SignUp, type: :model do
  include_context 'get into teaching api stubbed endpoints'

  before do
    FeatureFlag.activate(:adviser_sign_up)

    allow(AdviserSignUpWorker).to receive(:perform_async)
  end

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

  describe '#available?' do
    it { is_expected.to be_available }

    context 'when the feature is inactive' do
      before { FeatureFlag.deactivate(:adviser_sign_up) }

      it { is_expected.not_to be_available }
    end

    context 'when the application form is not applicable' do
      let(:application_form) { create(:application_form) }

      it { is_expected.not_to be_available }
    end
  end

  describe '#teaching_subjects' do
    it 'returns teaching subjects' do
      expect(sign_up.teaching_subjects).to contain_exactly(preferred_teaching_subject)
    end
  end

  describe '#save' do
    it 'enqueues a AdviserSignUpWorker job' do
      expect(sign_up.save).to be(true)
      expect(AdviserSignUpWorker).to have_received(:perform_async).with(
        application_form.id,
        preferred_teaching_subject.id,
      )
    end

    context 'when not available' do
      before { FeatureFlag.deactivate(:adviser_sign_up) }

      it 'raises an error and does not enqueue a AdviserSignUpWorker job' do
        expect { sign_up.save }.to raise_error(described_class::AdviserSignUpUnavailableError)
        expect(AdviserSignUpWorker).not_to have_received(:perform_async)
      end
    end

    context 'when invalid' do
      let(:preferred_teaching_subject) { nil }

      it 'does not enqueue a AdviserSignUpWorker job' do
        expect(sign_up.save).to be(false)
        expect(AdviserSignUpWorker).not_to have_received(:perform_async)
      end
    end
  end
end
