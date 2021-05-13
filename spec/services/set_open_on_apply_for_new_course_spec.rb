require 'rails_helper'

RSpec.describe SetOpenOnApplyForNewCourse do
  let(:course) { create(:course, open_on_apply: false) }

  subject(:course_opener) { SetOpenOnApplyForNewCourse.new(course) }

  context 'in Sandbox', sandbox: true do
    it 'opens the course' do
      course_opener.call

      expect(course).to be_open_on_apply
    end
  end

  context 'the course was open in the previous cycle' do
    before do
      create(:course, provider: course.provider, code: course.code, recruitment_cycle_year: RecruitmentCycle.previous_year, open_on_apply: true)
    end

    it 'opens the course' do
      course_opener.call

      expect(course).to be_open_on_apply
    end
  end

  context 'the provider has open courses in the current cycle', sidekiq: true do
    before do
      create(:course, provider: course.provider, open_on_apply: true)
    end

    it 'notifies slack about the new course' do
      create(:course, :open_on_apply, provider: course.provider) # existing course

      course_opener.call

      expect_slack_message_with_text("#{course.provider.name}, which has courses open on Apply, added a new course. There’s no separate accredited body for this course.")
    end

    it 'does not notify Slack when the provider does not have open courses on Apply in this cycle' do
      create(:course, :open_on_apply, provider: course.provider, recruitment_cycle_year: RecruitmentCycle.previous_year)

      course_opener.call

      expect_no_slack_message
    end

    context 'when the course has an accredited provider' do
      let(:accredited_provider) { create(:provider, name: 'Canterbury') }
      let(:course) { create(:course, open_on_apply: false, accredited_provider: accredited_provider) }

      it 'includes the accredited provider details and the DSA status' do
        create(:course, :open_on_apply, provider: course.provider) # existing course

        course_opener.call

        expect_slack_message_with_text("#{course.provider.name}, which has courses open on Apply, added a new course. It’s ratified by Canterbury, who have NOT signed the DSA.")
      end

      context 'and the accredited provider has signed the DSA' do
        let(:accredited_provider) { create(:provider, :with_signed_agreement, name: 'Canterbury') }

        it 'includes the accredited provider details and the DSA status' do
          create(:course, :open_on_apply, provider: course.provider) # existing course

          course_opener.call

          expect_slack_message_with_text("#{course.provider.name}, which has courses open on Apply, added a new course. It’s ratified by Canterbury, who have signed the DSA.")
        end
      end
    end
  end
end
