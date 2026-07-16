require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultService do
  describe '#call' do
    it 'only rejects application choices in rejectable states on September courses', time: after_reject_by_default do
      application_form = create(:application_form)
      inactive_choice = create(:application_choice, :inactive, application_form:)
      interviewing_choice = create(:application_choice, :interviewing, application_form:)
      awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      offered_choice = create(:application_choice, :offer, application_form:)
      jan_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      jan_course = jan_choice.course
      jan_course.update!(start_date: "01/01/#{jan_course.start_date.year + 1}")

      described_class.new(application_form).call

      expect(inactive_choice.reload.status).to eq('rejected')
      expect(inactive_choice.rejected_by_default).to be(true)
      expect(interviewing_choice.reload.status).to eq('rejected')
      expect(interviewing_choice.rejected_by_default).to be(true)
      expect(awaiting_decision_choice.reload.status).to eq('rejected')
      expect(awaiting_decision_choice.rejected_by_default).to be(true)

      expect(offered_choice.reload.status).to eq('offer')
      expect(offered_choice.rejected_by_default).to be(false)

      expect(jan_choice.reload.status).to eq('awaiting_provider_decision')
      expect(jan_choice.rejected_by_default).to be(false)
    end

    it 'cancels interviews for application choices on September courses', time: after_reject_by_default do
      application_form = create(:application_form)
      interviewing_choice = create(:application_choice, :interviewing, application_form:)
      interview = interviewing_choice.interviews.kept.upcoming_not_today.first
      jan_choice = create(:application_choice, :interviewing, application_form:)
      jan_course = jan_choice.course
      jan_course.update!(start_date: "01/01/#{jan_course.start_date.year + 1}")
      jan_interview = jan_choice.interviews.kept.upcoming_not_today.first

      described_class.new(application_form).call

      expect(interview.reload.cancellation_reason).to eq('Your application was unsuccessful.')
      expect(jan_interview.reload.cancellation_reason).to be_nil
    end

    it 'only rejects application choices in rejectable states on courses starting after September', time: after_winter_reject_by_default do
      application_form = create(:application_form, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)
      inactive_choice = create(:application_choice, :inactive, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      interviewing_choice = create(:application_choice, :interviewing, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      offered_choice = create(:application_choice, :offer, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      [inactive_choice, interviewing_choice, awaiting_decision_choice, offered_choice].each do |choice|
        course = choice.course
        course.update!(start_date: "01/01/#{application_form.recruitment_cycle_year + 1}")
      end
      sept_choice = create(:application_choice, :awaiting_provider_decision, application_form:, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)
      sept_course = sept_choice.course
      sept_course.update!(start_date: "01/09/#{application_form.recruitment_cycle_year}")

      described_class.new(application_form).call

      expect(inactive_choice.reload.status).to eq('rejected')
      expect(inactive_choice.rejected_by_default).to be(true)
      expect(interviewing_choice.reload.status).to eq('rejected')
      expect(interviewing_choice.rejected_by_default).to be(true)
      expect(awaiting_decision_choice.reload.status).to eq('rejected')
      expect(awaiting_decision_choice.rejected_by_default).to be(true)

      expect(offered_choice.reload.status).to eq('offer')
      expect(offered_choice.rejected_by_default).to be(false)

      expect(sept_choice.reload.status).to eq('awaiting_provider_decision')
      expect(sept_choice.rejected_by_default).to be(false)
    end

    it 'cancels interviews for application choices on courses after September', time: after_winter_reject_by_default do
      application_form = create(:application_form, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)
      sept_interviewing_choice = create(:application_choice, :interviewing, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      sept_course = sept_interviewing_choice.course
      sept_course.update!(start_date: "01/09/#{application_form.recruitment_cycle_year}")
      sept_interview = sept_interviewing_choice.interviews.kept.upcoming_not_today.first

      jan_choice = create(:application_choice, :interviewing, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      jan_course = jan_choice.course
      jan_course.update!(start_date: "01/01/#{application_form.recruitment_cycle_year + 1}")
      jan_interview = jan_choice.interviews.kept.upcoming_not_today.first

      described_class.new(application_form).call

      expect(jan_interview.reload.cancellation_reason).to eq('Your application was unsuccessful.')
      expect(sept_interview.reload.cancellation_reason).to be_nil
    end
  end
end
