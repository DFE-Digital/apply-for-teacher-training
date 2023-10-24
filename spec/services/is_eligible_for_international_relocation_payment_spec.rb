require 'rails_helper'

RSpec.describe IsEligibleForInternationalRelocationPayment do
  describe '#call' do
    subject { described_class.new(application_choice).call }

    let(:application_form) do
      create(:application_form, :international_address, first_nationality:, right_to_work_or_study:)
    end
    let(:course) { create(:course, subjects: [course_subject]) }
    let(:course_option) { create(:course_option, course:) }
    let(:application_choice) { create(:application_choice, course_option:, application_form:) }
    let(:first_nationality) { 'Azeri' }
    let(:right_to_work_or_study) { 'yes' }
    let(:course_subject) { create(:subject, name: 'Colloquial Amaraic', code: 'A0') }

    context 'application meets all criteria' do
      it { is_expected.to be true }
    end

    context 'right_to_work_or_study set to decide later' do
      let(:right_to_work_or_study) { 'decide_later' }

      it { is_expected.to be true }
    end

    context 'subject is physics' do
      let(:course_subject) { create(:subject, name: 'Advanced Quantum Computing', code: 'F0') }

      it { is_expected.to be true }
    end

    context 'subject is spanish' do
      let(:course_subject) { create(:subject, name: 'Spanish with Sichuanese', code: '15') }

      it { is_expected.to be true }
    end

    context 'subject not eligible' do
      let(:course_subject) { create(:subject, name: 'Zoroastrian Cosmology', code: 'V6') }

      it { is_expected.to be false }
    end

    context 'british nationality' do
      let(:first_nationality) { 'British' }

      it { is_expected.to be false }
    end

    context 'does not have right to work or study' do
      let(:right_to_work_or_study) { 'no' }

      it { is_expected.to be false }
    end

    context 'not an international applicant' do
      let(:application_form) { create(:application_form, first_nationality:, right_to_work_or_study:) }

      it { is_expected.to be false }
    end
  end
end
