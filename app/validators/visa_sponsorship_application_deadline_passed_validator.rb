class VisaSponsorshipApplicationDeadlinePassedValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper
  def validate_each(record, attribute, application_choice)
    return unless FeatureFlag.active?(:early_application_deadlines_for_candidates_with_visa_sponsorship)
    return unless application_choice.application_form.right_to_work_or_study == 'no'

    deadline = application_choice.course.visa_sponsorship_application_deadline_at
    return if deadline.nil? || deadline.after?(Time.zone.now)

    record.errors.add(
      attribute,
      :visa_sponsorship_application_deadline_passed,
      link_to_find:,
    )
  end

  def link_to_find
    govuk_link_to(
      'Find a different course to apply to',
      I18n.t('find_teacher_training.production_url'),
    )
  end
end
