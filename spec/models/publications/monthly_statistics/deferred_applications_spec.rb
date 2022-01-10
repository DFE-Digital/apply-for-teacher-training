require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::DeferredApplications do
  describe '#count' do
    around do |example|
      ApplicationForm.with_unsafe_application_choice_touches { example.run }
    end

    it 'returns the correct value' do
      create(
        :completed_application_form,
        recruitment_cycle_year: RecruitmentCycle.current_year,
        application_choices: [
          create(
            :application_choice,
            :pending_conditions,
            current_recruitment_cycle_year: RecruitmentCycle.current_year,
          ),
        ],
      )
      create(
        :completed_application_form,
        recruitment_cycle_year: RecruitmentCycle.previous_year,
        application_choices: [
          create(
            :application_choice,
            :pending_conditions,
            current_recruitment_cycle_year: RecruitmentCycle.current_year,
          ),
        ],
      )
      expect(described_class.new.count).to be(1)
    end
  end
end
