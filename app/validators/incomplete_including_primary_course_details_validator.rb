class IncompleteIncludingPrimaryCourseDetailsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return unless science_gcse_incomplete_and_others?(application_choice)

    record.errors.add(
      attribute,
      :incomplete_details_including_primary_course_details,
      link_to_details:,
    )
  end

private

  def link_to_details
    view.govuk_link_to('Add your science GCSE grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_continuous_applications_details_path)
  end

  def view
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end

  def science_gcse_incomplete_and_others?(application_choice)
    sections(application_choice).incomplete_sections.length > 1 &&
      sections(application_choice).incomplete_sections.any? { |section| section.name == :science_gcse }
  end

  def sections(application_choice)
    @sections ||= CandidateInterface::ApplicationFormSections.new(application_form: application_choice.application_form, application_choice:)
  end
end
