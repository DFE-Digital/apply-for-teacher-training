module CandidateInterface
  class CarryOverBetweenCyclesComponentPreview < ViewComponent::Preview
    def with_application_choices
      application_form = FactoryBot.create(
        :application_form,
        recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
      )
      FactoryBot.create(:application_choice, status: 'application_not_sent', application_form:)
      render CarryOverBetweenCyclesComponent.new(application_form:)
    end

    def without_application_choices
      recruitment_cycle_year = RecruitmentCycleTimetable.previous_year
      render CarryOverBetweenCyclesComponent.new(
        application_form: FactoryBot.build_stubbed(:application_form, recruitment_cycle_year:),
      )
    end
  end
end
