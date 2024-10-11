class IncompletePostgraduateCourseDetailsValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  def validate_each(record, attribute, application_choice)
    return if application_choice.course.undergraduate?

    if application_choice.application_form.no_degree_and_degree_completed?
      record.errors.add(
        attribute,
        :incomplete_postgraduate_course_details,
        link_to_degree:,
      )
    end
  end

  def link_to_degree
    govuk_link_to(
      'Add your degree (or equivalent)',
      Rails.application.routes.url_helpers.candidate_interface_degree_university_degree_path,
    )
  end
end
