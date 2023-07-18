require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::WhichCourseAreYouApplyingToStep do
  subject(:which_course_are_you_applying_to_step) { described_class.new(course_id: course_id) }

  let(:course_id) { 123 }

  it 'returns the correct next step' do
    expect(which_course_are_you_applying_to_step.next_step).to eq(:todo)
  end

  xcontext 'when no course_id given' do
    let(:course_id) { nil }

    it 'validation fails' do
      expect(which_course_are_you_applying_to_step).not_to be_valid
    end
  end

  xcontext 'when valid course_id given' do
    it 'validation passes' do
      expect(which_course_are_you_applying_to_step).to be_valid
    end
  end
end
