require 'rails_helper'

RSpec.describe ApplicationChoicesVisaSponsorshipDeadlineReminder do
  describe '#call' do
    it 'returns the choices with approaching visa sponsorship deadlines' do
      provider = create(:provider)
      course = create(
        :course,
        provider: provider,
        visa_sponsorship_application_deadline_at: 2.weeks.from_now,
      )
      course_option = create(:course_option, course:)
      application_form = create(
        :application_form,
        :minimum_info,
        right_to_work_or_study: 'no',
      )
      application_choice = create(
        :application_choice,
        application_form:,
        status: 'unsubmitted',
        current_course_option: course_option,
      )

      course_deadline_2_month_from_now = create(
        :course,
        provider: provider,
        visa_sponsorship_application_deadline_at: 2.months.from_now,
      )
      course_option_2_months_from_now = create(
        :course_option,
        course: course_deadline_2_month_from_now,
      )
      _application_choice_2_months_from_now = create(
        :application_choice,
        application_form:,
        status: 'unsubmitted',
        current_course_option: course_option_2_months_from_now,
      )

      course_with_chaser = create(
        :course,
        provider: provider,
        visa_sponsorship_application_deadline_at: 2.weeks.from_now,
      )
      _chaser_sent = create(
        :chaser_sent,
        chaser_type: 'visa_sponsorship_deadline',
        course_id: course_with_chaser.id,
      )
      course_option_with_chaser = create(
        :course_option,
        course: course_deadline_2_month_from_now,
      )
      _application_with_chaser = create(
        :application_choice,
        application_form:,
        status: 'unsubmitted',
        current_course_option: course_option_with_chaser,
      )

      _random_application_choice = create(
        :application_choice,
        application_form:,
        status: 'unsubmitted',
      )

      _submitted_random_application_choice = create(
        :application_choice,
        application_form:,
        status: 'awaiting_provider_decision',
      )

      expect(described_class.call).to eq([application_choice])
    end
  end
end
