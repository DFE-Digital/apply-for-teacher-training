class ImmigrationStatusValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  VISAS_REQUIRING_SPONSORSHIP = %w[student_visa skilled_worker_visa].freeze

  def validate_each(record, attribute, application_choice)
    return if did_not_add_nationality_yet?(application_choice) ||
              british_or_irish?(application_choice) ||
              not_requiring_sponsorship?(application_choice) ||
              course_can_sponsor_visa?(application_choice)

    record.errors.add(attribute, :immigration_status, link_to_find:)
  end

  def british_or_irish?(application_choice)
    application_choice.application_form.british_or_irish?
  end

  def not_requiring_sponsorship?(application_choice)
    application_choice.application_form.right_to_work_or_study_yes? &&
      !application_choice.application_form.immigration_status.in?(VISAS_REQUIRING_SPONSORSHIP)
  end

  def course_can_sponsor_visa?(application_choice)
    application_choice.course.can_sponsor_skilled_worker_visa? ||
      application_choice.course.can_sponsor_student_visa?
  end

  def link_to_find
    govuk_link_to('Find a course that has visa sponsorship', url_helpers.find_url, target: '_blank', rel: 'nofollow')
  end

private

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def did_not_add_nationality_yet?(application_choice)
    application_choice.application_form.nationalities.blank?
  end
end
