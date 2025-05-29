module CandidateInterface
  class CarryOverMidCycleComponentPreview < ViewComponent::Preview
    def application_from_many_years_ago
      recruitment_cycle_year = RecruitmentCycleTimetable.current_year - 3
      render CandidateInterface::CarryOverMidCycleComponent.new(
        application_form: FactoryBot.build_stubbed(:application_form, recruitment_cycle_year:),
      )
    end

    def application_from_previous_year
      recruitment_cycle_year = RecruitmentCycleTimetable.current_year - 1
      render CandidateInterface::CarryOverMidCycleComponent.new(
        application_form: FactoryBot.build_stubbed(:application_form, recruitment_cycle_year:),
      )
    end
  end
end
