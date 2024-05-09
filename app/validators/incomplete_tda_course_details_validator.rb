class IncompleteTdaCourseDetailsValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  def validate_each(record, attribute, application_choice)
    return unless application_choice.degree_apprenticeship?

    application_form = application_choice.application_form
    course_level = application_choice.current_course.level

    if application_form.application_qualifications.a_levels.blank?
      record.errors.add(
        attribute,
        :incomplete_details_a_levels,
        link_to_details:,
        course_level:,
        course_subject: 'Mathematics',
      )
    end
  end

  def link_to_details
    govuk_link_to('Add your A level grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_other_qualification_type_path)
  end
end
