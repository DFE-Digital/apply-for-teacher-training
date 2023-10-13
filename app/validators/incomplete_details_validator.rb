class IncompleteDetailsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return unless details_incomplete_and_science_gcse_not_needed?(application_choice)

    record.errors.add(
      attribute,
      :incomplete_details,
      link_to_details:,
    )
  end

private

  def link_to_details
    view.govuk_link_to('complete your details', Rails.application.routes.url_helpers.candidate_interface_continuous_applications_details_path)
  end

  def view
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end

  def details_incomplete_and_science_gcse_not_needed?(application_choice)
    sections = CandidateInterface::ApplicationFormSections.new(application_form: application_choice.application_form, application_choice:)

    sections.incomplete_sections.present? && sections.incomplete_sections.none? { |section| section.name == :science_gcse }
  end
end
