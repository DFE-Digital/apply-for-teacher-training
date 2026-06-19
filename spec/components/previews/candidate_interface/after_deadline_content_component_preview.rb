class CandidateInterface::AfterDeadlineContentComponentPreview < ViewComponent::Preview
  def no_applications
    render CandidateInterface::AfterDeadlineContentComponent.new(application_form:)
  end

  def only_september_applications
    component = PreviewAfterDeadlineContentComponent.new(application_form:)
    component.application_choices
    render component
  end

  def only_january_applications
    component = PreviewAfterDeadlineContentComponent.new(application_form:, september_courses: false, january_courses: true)
    component.application_choices
    render component
  end

  def september_and_january_applications
    component = PreviewAfterDeadlineContentComponent.new(application_form:, september_courses: true, january_courses: true)
    component.application_choices
    render component
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewAfterDeadlineContentComponent < CandidateInterface::AfterDeadlineContentComponent
    def initialize(application_form:, september_courses: true, january_courses: false)
      super(application_form:)
      @september_courses = september_courses
      @january_courses = january_courses
    end

    def application_choices
      @application_choices ||= begin
                                 provider = FactoryBot.build(:provider)
                                 if @september_courses
                                   sept_course = FactoryBot.build(:course, provider:)
                                   sept_course_option = FactoryBot.build(:course_option, course: sept_course)
                                   FactoryBot.create(:application_choice, application_form:, course_option: sept_course_option)
                                 end

                                 if @january_courses
                                   jan_course = FactoryBot.build(:course, provider:, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}")
                                   jan_course_option = FactoryBot.build(:course_option, course: jan_course)
                                   FactoryBot.create(:application_choice, application_form:, course_option: jan_course_option)
                                 end

                                 CandidateInterface::SortApplicationChoices.call(
                                   application_choices: @application_form.application_choices.for_sorting,
                                 )
                               end
    end
  end
end
