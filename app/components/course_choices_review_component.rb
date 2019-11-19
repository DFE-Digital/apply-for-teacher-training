class CourseChoicesReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, deletable: true)
    @application_form = application_form
    @course_choices = @application_form.application_choices
    @deletable = deletable
  end

  def course_choice_rows(course_choice)
    [
      course_row(course_choice),
      location_row(course_choice),
    ]
  end

private

  attr_reader :application_form

  def course_row(course_choice)
    {
      key: 'Course',
      value: "#{course_choice.course.name} (#{course_choice.course.code})",
    }
  end

  def location_row(course_choice)
    {
      key: 'Location',
      value: course_choice.site.name,
    }
  end
end
