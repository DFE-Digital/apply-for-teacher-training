class GetCoursesNotYetOpenForApplication
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.application_choices.reject { |choice| choice.course.open_for_applications? }.map(&:course)
  end
end
