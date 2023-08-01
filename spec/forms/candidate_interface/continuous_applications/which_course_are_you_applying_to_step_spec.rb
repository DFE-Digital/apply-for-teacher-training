require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::WhichCourseAreYouApplyingToStep do
  subject(:which_course_are_you_applying_to_step) { described_class.new(provider_id:, course_id:) }

  let(:provider_id) { nil }
  let(:course_id) { nil }

  describe 'validations' do
    it 'errors on course id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:course_id)
    end

    it 'errors on provider id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:provider_id)
    end
  end

  describe '#next_step' do
    let(:provider) { create(:provider) }
    let(:course) do
      create(
        :course,
        :with_both_study_modes,
        :open_on_apply,
        provider:,
        name: 'Software Engineering',
      )
    end
    let(:provider_id) { provider.id }
    let(:course_id) { course.id }

    context 'when course has multiple study modes' do
      before do
        create(
          :course_option,
          course:,
          study_mode: :part_time,
        )
        create(
          :course_option,
          course:,
          study_mode: :part_time,
        )
        create(
          :course_option,
          course:,
          study_mode: :full_time,
        )
      end

      it 'returns :course_study_mode' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_study_mode)
      end
    end

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_site' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_site)
      end
    end

    context 'when course has single site and single study mode' do
      before do
        create(:course_option, course:)
      end

      it 'returns :course_review' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_review)
      end
    end
  end
end
