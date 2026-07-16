require 'rails_helper'

RSpec.describe EndOfCycle::DeclineByDefaultService do
  describe '#call' do
    it 'only declines application choices in offer states on September courses', time: after_decline_by_default do
      application_form = create(:application_form)
      inactive_choice = create(:application_choice, :inactive, application_form:)
      interviewing_choice = create(:application_choice, :interviewing, application_form:)
      awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      offered_choice = create(:application_choice, :offer, application_form:)
      jan_choice = create(:application_choice, :offer, application_form:)
      jan_course = jan_choice.course
      jan_course.update!(start_date: "01/01/#{jan_course.start_date.year + 1}")

      described_class.new(application_form).call

      expect(inactive_choice.reload.status).to eq('inactive')
      expect(inactive_choice.declined_by_default).to be(false)
      expect(interviewing_choice.reload.status).to eq('interviewing')
      expect(interviewing_choice.declined_by_default).to be(false)
      expect(awaiting_decision_choice.reload.status).to eq('awaiting_provider_decision')
      expect(awaiting_decision_choice.declined_by_default).to be(false)

      expect(offered_choice.reload.status).to eq('declined')
      expect(offered_choice.declined_by_default).to be(true)

      expect(jan_choice.reload.status).to eq('offer')
      expect(jan_choice.declined_by_default).to be(false)
    end

    it 'only declines application choices in offer states on courses after September', time: after_winter_decline_by_default do
      application_form = create(:application_form, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)
      inactive_choice = create(:application_choice, :inactive, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      interviewing_choice = create(:application_choice, :interviewing, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      sept_offered_choice = create(:application_choice, :offer, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      sept_course = sept_offered_choice.course
      sept_course.update!(start_date: "01/09/#{application_form.recruitment_cycle_year}")
      jan_choice = create(:application_choice, :offer, application_form:, current_recruitment_cycle_year: application_form.recruitment_cycle_year)
      jan_course = jan_choice.course
      jan_course.update!(start_date: "01/01/#{jan_course.start_date.year + 1}")

      described_class.new(application_form).call

      expect(inactive_choice.reload.status).to eq('inactive')
      expect(inactive_choice.declined_by_default).to be(false)
      expect(interviewing_choice.reload.status).to eq('interviewing')
      expect(interviewing_choice.declined_by_default).to be(false)
      expect(awaiting_decision_choice.reload.status).to eq('awaiting_provider_decision')
      expect(awaiting_decision_choice.declined_by_default).to be(false)

      expect(sept_offered_choice.reload.status).to eq('offer')
      expect(sept_offered_choice.declined_by_default).to be(false)

      expect(jan_choice.reload.status).to eq('declined')
      expect(jan_choice.declined_by_default).to be(true)
    end
  end
end
