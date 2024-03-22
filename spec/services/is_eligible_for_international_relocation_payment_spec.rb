require 'rails_helper'

RSpec.describe IsEligibleForInternationalRelocationPayment do
  describe '#call' do
    subject(:eligibility) { described_class.new(application_choice).call }

    let(:application_form) do
      create(:application_form, :international_address, first_nationality:, right_to_work_or_study:)
    end
    let(:course) { create(:course, subjects: [course_subject]) }
    let(:course_option) { create(:course_option, course:) }
    let(:application_choice) { create(:application_choice, course_option:, application_form:) }
    let(:first_nationality) { 'Azeri' }
    let(:right_to_work_or_study) { 'yes' }
    let(:course_subject) { create(:subject, name: 'Quantum Mechanics', code: 'F0') }

    context 'application meets all criteria' do
      it 'returns expected value' do
        if FeatureFlag.active? :hide_international_relocation_payment
          expect(eligibility).to be false
        else
          expect(eligibility).to be true
        end
      end
    end

    context 'right_to_work_or_study set to decide later' do
      let(:right_to_work_or_study) { 'decide_later' }

      it 'returns expected value' do
        if FeatureFlag.active? :hide_international_relocation_payment
          expect(eligibility).to be false
        else
          expect(eligibility).to be true
        end
      end
    end

    context 'subject is physics' do
      let(:course_subject) { create(:subject, name: 'Advanced Quantum Computing', code: 'F0') }

      it 'returns expected value' do
        if FeatureFlag.active? :hide_international_relocation_payment
          expect(eligibility).to be false
        else
          expect(eligibility).to be true
        end
      end
    end

    context 'subject is modern foreign languages' do
      let(:course_subject) { create(:subject, name: 'Russian', code: '21') }

      # Always false, regardless of feature flag
      it { is_expected.to be false }
    end

    context 'subject is french' do
      let(:course_subject) { create(:subject, name: 'French', code: '15') }

      it 'returns expected value' do
        if FeatureFlag.active? :hide_international_relocation_payment
          expect(eligibility).to be false
        else
          expect(eligibility).to be true
        end
      end
    end

    context 'subject not eligible' do
      let(:course_subject) { create(:subject, name: 'Zoroastrian Cosmology', code: 'V6') }

      # Always false, regardless of feature flag
      it { is_expected.to be false }
    end

    context 'british nationality' do
      let(:first_nationality) { 'British' }

      # Always false, regardless of feature flag
      it { is_expected.to be false }
    end

    context 'does not have right to work or study' do
      let(:right_to_work_or_study) { 'no' }

      # Always false, regardless of feature flag
      it { is_expected.to be false }
    end

    context 'not an international applicant' do
      let(:application_form) { create(:application_form, first_nationality:, right_to_work_or_study:) }

      # Always false, regardless of feature flag
      it { is_expected.to be false }
    end
  end
end
