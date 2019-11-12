class VolunteeringReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @volunteering_roles = CandidateInterface::VolunteeringRoleForm.build_all_from_application(
      @application_form,
    )
  end

  def volunteering_role_rows(volunteering_role)
    [
      role_row(volunteering_role),
      organisation_row(volunteering_role),
      length_and_details_row(volunteering_role),
    ]
  end

private

  attr_reader :application_form

  def role_row(volunteering_role)
    {
      key: t('application_form.volunteering.role.review_label'),
      value: volunteering_role.role,
      action: t('application_form.volunteering.role.change_action'),
      change_path: '#',
    }
  end

  def organisation_row(volunteering_role)
    {
      key: t('application_form.volunteering.organisation.review_label'),
      value: volunteering_role.organisation,
      action: t('application_form.volunteering.organisation.change_action'),
      change_path: '#',
    }
  end

  def length_and_details_row(volunteering_role)
    {
      key: t('application_form.volunteering.length_and_details.review_label'),
      value: formatted_length_and_details(volunteering_role),
      action: t('application_form.volunteering.length_and_details.change_action'),
      change_path: '#',
    }
  end

  def formatted_length_and_details(volunteering_role)
    [
      "#{formatted_start_date(volunteering_role)} - #{formatted_end_date(volunteering_role)}",
      simple_format(volunteering_role.details),
    ]
  end

  def formatted_start_date(volunteering_role)
    volunteering_role.start_date.strftime('%B %Y')
  end

  def formatted_end_date(volunteering_role)
    return 'Present' if volunteering_role.end_date.nil? || volunteering_role.end_date == DateTime.now

    volunteering_role.end_date.strftime('%B %Y')
  end
end
