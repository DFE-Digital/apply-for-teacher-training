class GetAllChangeOptionsFromOfferedOption
  attr_accessor :application_choice, :available_providers
  attr_accessor :available_courses, :available_course_options

  def initialize(application_choice:, available_providers: nil)
    @application_choice = application_choice

    @available_providers = available_providers || [application_choice.offered_course.provider]

    @available_courses = \
      Course.where(
        open_on_apply: true,
        provider: application_choice.offered_course.provider,
        study_mode: study_mode_for_other_courses,
      ).order(:name)

    @available_course_options = \
      CourseOption.where(
        course: application_choice.offered_course,
        study_mode: application_choice.offered_option.study_mode, # preserving study_mode, for now
        # TODO: check vacancy_status, e.g. 'B'
      ).includes(:site).order('sites.name')
  end

  def call
    {
      available_providers: available_providers,
      available_courses: available_courses,
      available_course_options: available_course_options,
    }
  end

private

  def study_mode_for_other_courses
    current_study_mode = @application_choice.offered_option.study_mode
    [current_study_mode, :full_time_or_part_time]
  end
end
