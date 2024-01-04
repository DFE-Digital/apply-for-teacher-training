class IncompleteIncludingPrimaryCourseDetailsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    application_form_sections = CandidateInterface::ApplicationFormSections.new(
      application_choice:,
      application_form: application_choice.application_form,
    )
    return unless application_form_sections.science_gcse_incomplete_and_others?

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
end
