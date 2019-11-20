class CourseChoicesReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true)
    @application_form = application_form
    @course_choices = @application_form.application_choices
    @editable = editable
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

  def status_row(course_choice)
    type =  case course_choice.status
            when 'awaiting_references', 'application_complete'
              :secondary
            when 'awaiting_provider_decision'
              :primary
            when 'offer'
              :info_unfilled
            when 'rejected'
              :danger
            when 'pending_conditions'
              :info
            when 'declined'
              :warning
            else
              ''
            end
    {
      key: 'Status',
      value: render(TagComponent, text: t("application_states.#{course_choice.status}"), type: type),
    }
  end
end
