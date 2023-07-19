require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::WhichCourseAreYouApplyingToStep do
  subject(:which_course_are_you_applying_to_step) { described_class.new(course_id: course_id) }

  let(:course_id) { 123 }

  xit 'returns the correct next step' do
    expect(which_course_are_you_applying_to_step.next_step).to eq(:todo)
  end

  context 'when no course_id given' do
    let(:course_id) { nil }

    it 'validation fails' do
      expect(which_course_are_you_applying_to_step).not_to be_valid
    end

    it 'errors on course id' do
      which_course_are_you_applying_to_step.valid?
      expect(which_course_are_you_applying_to_step.errors[:course_id]).to include("can't be blank")
    end

    it 'errors on provider id' do
      which_course_are_you_applying_to_step.valid?
      expect(which_course_are_you_applying_to_step.errors[:provider_id]).to include("can't be blank")
    end
  end

  xcontext 'when valid course_id given' do
    it 'validation passes' do
      expect(which_course_are_you_applying_to_step).to be_valid
    end
  end
end
