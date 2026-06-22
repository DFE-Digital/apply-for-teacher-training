class CandidateInterface::MidCycleContentComponentPreview < ViewComponent::Preview
  def no_applications
    render CandidateInterface::MidCycleContentComponent.new(application_form:)
  end

  def no_title
    component = PreviewMidCycleContentComponent.new(application_form:, with_title: false)
    component.application_choices
    render component
  end

  def with_applications
    component = PreviewMidCycleContentComponent.new(application_form:)
    component.application_choices
    render component
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewMidCycleContentComponent < CandidateInterface::MidCycleContentComponent
    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider, code: Provider.pluck(:code).max.next)

        sept_course = FactoryBot.build(:course, provider:)
        sept_course_option = FactoryBot.build(:course_option, course: sept_course)
        FactoryBot.create(:application_choice, application_form:, course_option: sept_course_option)

        jan_course = FactoryBot.build(:course, provider:, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}")
        jan_course_option = FactoryBot.build(:course_option, course: jan_course)
        FactoryBot.create(:application_choice, application_form:, course_option: jan_course_option)

        CandidateInterface::SortApplicationChoices.call(
          application_choices: @application_form.application_choices.for_sorting,
        )
      end
    end
  end
end
