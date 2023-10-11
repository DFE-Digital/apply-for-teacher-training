class IncompletePrimaryCourseDetailsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return unless only_science_gcse_incomplete?(application_choice)

    record.errors.add(
      attribute,
      :incomplete_primary_course_details,
      link_to_science:,
    )
  end

private

  def link_to_science
    view.govuk_link_to('Add your science GCSE grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_new_gcse_science_grade_path)
  end

  def view
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end

  def only_science_gcse_incomplete?(application_choice)
    sections(application_choice).incomplete_sections.present? && sections(application_choice).incomplete_sections.all? { |section| section.name == :science_gcse }
  end

  def sections(application_choice)
    @sections ||= CandidateInterface::ApplicationFormSections.new(application_form: application_choice.application_form, application_choice:)
  end
end
