class ImmigrationStatusValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return if did_not_add_nationality_yet?(application_choice) ||
              immigration_right_to_work?(application_choice) ||
              course_can_sponsor_visa?(application_choice)

    record.errors.add(attribute, :immigration_status, link_to_find:)
  end

  def did_not_add_nationality_yet?(application_choice)
    application_choice.application_form.nationalities.blank?
  end

  def immigration_right_to_work?(application_choice)
    application_choice.application_form.british_or_irish? ||
      application_choice.application_form.right_to_work_or_study_yes?
  end

  def course_can_sponsor_visa?(application_choice)
    (application_choice.course.salary? && application_choice.course.can_sponsor_skilled_worker_visa?) ||
      (!application_choice.course.salary? && application_choice.course.can_sponsor_student_visa?)
  end

  def link_to_find
    view.govuk_link_to('Find a course that has visa sponsorship', url_helpers.find_url, target: '_blank', rel: 'nofollow')
  end

  def view
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
