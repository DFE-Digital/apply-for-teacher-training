class CourseUnavailableValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  def validate_each(record, attribute, application_choice)
    course = application_choice.current_course

    return if !course.full? &&
              application_choice.course_option.site_still_valid? &&
              course.exposed_in_find? &&
              course.application_status_open?

    if course.application_status_closed?
      record.errors.add(
        attribute,
        :course_closed,
        link_to_remove: link_to_remove(application_choice),
      )
    else
      record.errors.add(
        attribute,
        :course_unavailable,
        link_to_remove: link_to_remove(application_choice),
      )
    end
  end

private

  def link_to_remove(application_choice)
    govuk_link_to('Remove this application', Rails.application.routes.url_helpers.candidate_interface_course_choices_confirm_destroy_course_choice_path(application_choice.id))
  end
end
