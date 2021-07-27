require 'rails_helper'

RSpec.describe SetOpenOnApplyForNewCourse do
  let(:course) { create(:course, open_on_apply: false) }

  subject(:course_opener) { described_class.new(course) }

  context 'in Sandbox', sandbox: true do
    it 'opens the course' do
      course_opener.call

      expect(course).to be_open_on_apply
    end
  end

  context 'the provider has no courses in the current cycle' do
    it 'does not open the course' do
      course_opener.call

      expect(course).not_to be_open_on_apply
    end
  end

  context 'the provider has a course in the current cycle but it’s hidden in find' do
    before do
      create(:course, provider: course.provider, exposed_in_find: false)
    end

    it 'does not open the course' do
      course_opener.call

      expect(course).not_to be_open_on_apply
    end
  end

  context 'the provider has a course in the current cycle and it’s exposed in find but not open' do
    before do
      create(:course, provider: course.provider, exposed_in_find: true, open_on_apply: false)
    end

    it 'does not open the course' do
      course_opener.call

      expect(course).not_to be_open_on_apply
    end
  end

  context 'the provider ratifies an open course in the current cycle' do
    before do
      create(:course, :open_on_apply, accredited_provider: course.provider)
    end

    it 'does not open the course' do
      course_opener.call

      expect(course).not_to be_open_on_apply
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

      expect_slack_message_with_text("#{course.provider.name}, which has courses open on Apply, added #{course.name_and_code}. We opened it automatically. There’s no separate accredited body for this course.")
      expect_slack_message_with_text("support/courses/#{course.id}")
    end

    it 'does not notify Slack when the provider does not have open courses on Apply in this cycle' do
      create(:course, :open_on_apply, provider: course.provider, recruitment_cycle_year: RecruitmentCycle.previous_year)

      course_opener.call

      expect_no_slack_message
    end

    it 'opens the course if all the provider’s other courses are open on apply' do
      create(:course, :open_on_apply, provider: course.provider)

      course_opener.call

      expect(course).to be_open_on_apply
      expect_slack_message_with_text('We opened it automatically')
    end

    it 'does not open the course if all the provider’s other courses are not open on apply' do
      create(:course, :open_on_apply, provider: course.provider)
      create(:course, :ucas_only, provider: course.provider)

      course_opener.call

      expect(course).not_to be_open_on_apply
      expect_slack_message_with_text('We didn’t automatically open it')
    end

    context 'when the course has an accredited provider' do
      let(:accredited_provider) { create(:provider, name: 'Canterbury') }
      let(:course) { create(:course, open_on_apply: false, accredited_provider: accredited_provider) }

      it 'includes the accredited provider details and the DSA status' do
        create(:course, :open_on_apply, provider: course.provider) # existing course

        course_opener.call

        expect_slack_message_with_text("#{course.provider.name}, which has courses open on Apply, added #{course.name_and_code}. We opened it automatically. It’s ratified by Canterbury, who have NOT signed the DSA.")
      end

      context 'and the accredited provider has signed the DSA' do
        let(:accredited_provider) { create(:provider, :with_signed_agreement, name: 'Canterbury') }

        it 'includes the accredited provider details and the DSA status' do
          create(:course, :open_on_apply, provider: course.provider) # existing course

          course_opener.call

          expect_slack_message_with_text("#{course.provider.name}, which has courses open on Apply, added #{course.name_and_code}. We opened it automatically. It’s ratified by Canterbury, who have signed the DSA.")
        end
      end
    end
  end
end
