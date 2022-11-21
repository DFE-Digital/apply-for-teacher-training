class GetFullCoursesForApplication
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.application_choices
      .select { |choice| choice.course_option.no_vacancies? }
      .map(&:course)
  end
end
