require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::CourseStudyModeStep do
  subject(:which_course_are_you_applying_to_step) { described_class.new(provider_id:, course_id:) }

  let(:provider_id) { nil }
  let(:course_id) { nil }

  describe 'validations' do
    it 'errors on course id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:study_mode)
    end
  end

  describe '#next_step' do
    let(:provider) { create(:provider) }
    let(:course) do
      create(
        :course,
        :with_both_study_modes,
        provider:,
        name: 'Software Engineering',
      )
    end
    let(:provider_id) { provider.id }
    let(:course_id) { course.id }

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_site' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_site)
      end
    end

    context 'when course has single site' do
      let(:site) { create(:site, provider:) }

      before do
        create(:course_option, :full_time, course:, site:)
        create(:course_option, :part_time, course:, site:)
      end

      it 'returns :course_review' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_review)
      end
    end
  end
end
