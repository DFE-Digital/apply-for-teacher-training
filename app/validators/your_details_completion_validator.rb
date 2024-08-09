class YourDetailsCompletionValidator < ActiveModel::EachValidator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def validate_each(record, attribute, application_choice)
    sections = CandidateInterface::ApplicationFormSections.new(application_form: record.application_form, application_choice:)

    record.errors.add attribute, :incomplete_details unless sections.all_completed?

    return unless application_choice.science_gcse_needed? && !sections.completed?(:science_gcse)

    record.errors.add attribute, :science_gcse_missing
    record.errors.add attribute, link_to(science_gcse_missing_guide_error, candidate_interface_gcse_details_new_type_path(subject: :science), class: 'govuk-link')
  end

private

  def science_gcse_missing_guide_error
    I18n.t('activemodel.errors.models.candidate_interface/application_choice_submission.attributes.application_choice.science_gcse_missing_guide')
  end
end
