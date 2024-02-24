class IncompleteDetailsValidator < ActiveModel::EachValidator
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  def validate_each(record, attribute, application_choice)
    sections = CandidateInterface::ApplicationFormSections.new(
      application_form: application_choice.application_form,
      application_choice:,
    )
    return if sections.all_completed?

    record.errors.add(
      attribute,
      :incomplete_details,
      link_to_details:,
    )
  end

private

  def link_to_details
    govuk_link_to('complete your details', Rails.application.routes.url_helpers.candidate_interface_continuous_applications_details_path)
  end
end
