class IncompleteUndergraduateCourseDetailsValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  def validate_each(record, attribute, application_choice)
    return unless application_choice.course.teacher_degree_apprenticeship?

    if application_choice.application_form.no_other_qualifications?
      record.errors.add(
        attribute,
        :incomplete_undergraduate_course_details,
        link_to_a_levels:,
      )
    end
  end

  def link_to_a_levels
    govuk_link_to(
      'Add your A level grade (or equivalent)',
      Rails.application.routes.url_helpers.candidate_interface_other_qualification_type_path,
    )
  end
end
