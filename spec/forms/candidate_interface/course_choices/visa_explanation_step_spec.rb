require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::VisaExplanationStep do
  subject(:visa_explanation_step) do
    described_class.new(
      application_choice_id:,
      visa_explanation:,
      visa_explanation_details:,
    )
  end

  let(:application_choice_id) { nil }
  let(:visa_explanation) { nil }
  let(:visa_explanation_details) { nil }

  describe '.route_name' do
    subject { visa_explanation_step.class.route_name }

    it { is_expected.to eq('candidate_interface_course_choices_visa_explanation') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:application_choice_id) }
    it { is_expected.to validate_presence_of(:visa_explanation) }

    context "when visa_explanation is 'other'" do
      let(:visa_explanation) { 'other' }

      it { is_expected.to validate_presence_of(:visa_explanation_details) }
    end
  end

  describe '#next_step' do
    it 'returns :course_review' do
      expect(visa_explanation_step.next_step).to be(:course_review)
    end
  end

  describe '#next_step_path_arguments' do
    it 'returns the arguments' do
      expect(visa_explanation_step.next_step_path_arguments).to eq({ application_choice_id: })
    end
  end

  describe '#previous_step' do
    it 'returns :course_review' do
      expect(visa_explanation_step.previous_step).to be(:visa_expiry_interruption)
    end
  end

  describe '#previous_step_path_arguments' do
    it 'returns the arguments' do
      expect(visa_explanation_step.previous_step_path_arguments).to eq({ application_choice_id: })
    end
  end
end
