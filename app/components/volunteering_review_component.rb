class VolunteeringReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
    @application_form = application_form
    @volunteering_roles = CandidateInterface::VolunteeringRoleForm.build_all_from_application(
      @application_form,
    )
    @editable = editable
    @heading_level = heading_level
    @show_incomplete = show_incomplete
    @missing_error = missing_error
  end

  def volunteering_role_rows(volunteering_role)
    [
      role_row(volunteering_role),
      organisation_row(volunteering_role),
      length_row(volunteering_role),
      details_row(volunteering_role),
    ]
  end

  def show_missing_banner?
    @show_incomplete && !@application_form.volunteering_completed && @editable
  end

private

  attr_reader :application_form

  def role_row(volunteering_role)
    {
      key: t('application_form.volunteering.role.review_label'),
      value: volunteering_role.role,
      action: t('application_form.volunteering.role.change_action'),
      change_path: edit_path(volunteering_role),
    }
  end

  def organisation_row(volunteering_role)
    {
      key: t('application_form.volunteering.organisation.review_label'),
      value: volunteering_role.organisation,
      action: t('application_form.volunteering.organisation.change_action'),
      change_path: edit_path(volunteering_role),
    }
  end

  def length_row(volunteering_role)
    {
      key: t('application_form.volunteering.review_length.review_label'),
      value: formatted_length(volunteering_role),
      action: t('application_form.volunteering.review_length.change_action'),
      change_path: edit_path(volunteering_role),
    }
  end

  def details_row(volunteering_role)
    {
      key: t('application_form.volunteering.review_details.review_label'),
      value: formatted_details(volunteering_role),
      action: t('application_form.volunteering.review_details.change_action'),
      change_path: edit_path(volunteering_role),
    }
  end

  def formatted_length(volunteering_role)
    "#{formatted_start_date(volunteering_role)} - #{formatted_end_date(volunteering_role)}"
  end

  def formatted_details(volunteering_role)
    simple_format(volunteering_role.details)
  end

  def formatted_start_date(volunteering_role)
    volunteering_role.start_date.strftime('%B %Y')
  end

  def formatted_end_date(volunteering_role)
    return 'Present' if volunteering_role.end_date.nil? || volunteering_role.end_date == DateTime.now

    volunteering_role.end_date.strftime('%B %Y')
  end

  def edit_path(volunteering_role)
    Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(volunteering_role.id)
  end
end
