require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::DoYouKnowTheCourseStep do
  subject(:do_you_know_the_course_step) { described_class.new(answer: answer) }

  context 'when the answer is yes' do
    let(:answer) { 'yes' }

    it 'returns the correct next step' do
      expect(do_you_know_the_course_step.next_step).to eq(:provider_selection)
    end
  end

  context 'when the answer is no' do
    let(:answer) { 'no' }

    it 'returns the correct next step' do
      expect(do_you_know_the_course_step.next_step).to eq(:go_to_find_explanation)
    end
  end

  context 'when no answer given' do
    let(:answer) { nil }

    it 'validation fails' do
      expect(do_you_know_the_course_step).not_to be_valid
    end
  end

  context 'when valid answer given' do
    let(:answer) { 'yes' }

    it 'validation passes' do
      expect(do_you_know_the_course_step).to be_valid
    end
  end

  context 'when permitted_params called' do
    it 'returns the correct params' do
      expect(described_class.permitted_params).to eq([:answer])
    end
  end
end
