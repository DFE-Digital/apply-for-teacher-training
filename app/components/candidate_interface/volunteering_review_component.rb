module CandidateInterface
  class VolunteeringReviewComponent < ViewComponent::Base
    include ViewHelper
    include DateValidationHelper

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false, show_experience_advice: false, return_to_application_review: false)
      @application_form = application_form
      @volunteering_roles = CandidateInterface::VolunteeringRoleForm.build_all_from_application(
        @application_form,
      )
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @show_experience_advice = show_experience_advice
      @return_to_application_review = return_to_application_review
    end

    def volunteering_role_rows(volunteering_role)
      [
        role_row(volunteering_role),
        organisation_row(volunteering_role),
        working_with_children_row(volunteering_role),
        length_row(volunteering_role),
        details_row(volunteering_role),
      ]
    end

    def no_experience_row
      [
        {
          key: t('application_form.volunteering.experience.label'),
          value: 'No',
          action: t('application_form.volunteering.experience.change_action'),
          change_path: candidate_interface_volunteering_experience_path,
        },
      ]
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.volunteering_completed && @editable
    end

  private

    attr_reader :application_form, :show_experience_advice

    def role_row(volunteering_role)
      {
        key: t('application_form.volunteering.role.review_label'),
        value: volunteering_role.role,
        action: generate_action(volunteering_role: volunteering_role, attribute: t('application_form.volunteering.role.change_action')),
        change_path: edit_path(volunteering_role, return_to_params),
        data_qa: 'volunteering-role',
      }
    end

    def organisation_row(volunteering_role)
      {
        key: t('application_form.volunteering.organisation.review_label'),
        value: volunteering_role.organisation,
        action: generate_action(volunteering_role: volunteering_role, attribute: t('application_form.volunteering.organisation.change_action')),
        change_path: edit_path(volunteering_role, return_to_params),
        data_qa: 'volunteering-organisation',
      }
    end

    def working_with_children_row(volunteering_role)
      {
        key: t('application_form.volunteering.working_with_children.review_label'),
        value: volunteering_role.working_with_children ? 'Yes' : 'No',
        action: generate_action(volunteering_role: volunteering_role, attribute: t('application_form.volunteering.working_with_children.change_action')),
        change_path: edit_path(volunteering_role, return_to_params),
        data_qa: 'volunteering-working-with-children',
      }
    end

    def length_row(volunteering_role)
      {
        key: t('application_form.volunteering.length.review_label'),
        value: formatted_length(volunteering_role),
        action: generate_action(volunteering_role: volunteering_role, attribute: t('application_form.volunteering.length.change_action')),
        change_path: edit_path(volunteering_role, return_to_params),
        data_qa: 'volunteering-length',
      }
    end

    def details_row(volunteering_role)
      {
        key: t('application_form.volunteering.details.review_label'),
        value: formatted_details(volunteering_role),
        action: generate_action(volunteering_role: volunteering_role, attribute: t('application_form.volunteering.details.change_action')),
        change_path: edit_path(volunteering_role, return_to_params),
        data_qa: 'volunteering-details',
      }
    end

    def formatted_length(volunteering_role)
      "#{formatted_start_date(volunteering_role)} - #{formatted_end_date(volunteering_role)}"
    end

    def formatted_details(volunteering_role)
      simple_format(volunteering_role.details, class: 'govuk-body')
    end

    def formatted_start_date(volunteering_role)
      volunteering_role.start_date.to_s(:month_and_year)
    end

    def formatted_end_date(volunteering_role)
      return 'Present' if month_and_year_blank?(volunteering_role.end_date) || volunteering_role.end_date == Time.zone.now

      volunteering_role.end_date.to_s(:month_and_year)
    end

    def edit_path(volunteering_role, return_to_params)
      candidate_interface_edit_volunteering_role_path(volunteering_role.id, return_to_params)
    end

    def generate_action(volunteering_role:, attribute: '')
      if any_roles_with_same_role_and_organisation?(volunteering_role)
        "#{attribute.presence} for #{volunteering_role.role}, #{volunteering_role.organisation}"\
          ", #{formatted_start_date(volunteering_role)} to #{formatted_end_date(volunteering_role)}"
      else
        "#{attribute.presence} for #{volunteering_role.role}, #{volunteering_role.organisation}"
      end
    end

    def any_roles_with_same_role_and_organisation?(volunteering_role)
      roles = @application_form.application_volunteering_experiences.where(
        role: volunteering_role.role,
        organisation: volunteering_role.organisation,
      )
      roles.many?
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
