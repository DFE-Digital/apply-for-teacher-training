module CandidateInterface
  class Volunteering::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def new
      @volunteering_role = VolunteeringRoleForm.new
    end

    def create
      @volunteering_role = VolunteeringRoleForm.new(volunteering_role_params)

      if @volunteering_role.save(current_application)
        redirect_to candidate_interface_review_volunteering_path
      else
        render :new
      end
    end

    def edit
      @volunteering_role = VolunteeringRoleForm.build_from_application(current_application, current_volunteering_role_id)
    end

    def update
      @volunteering_role = VolunteeringRoleForm.new(volunteering_role_params)

      if @volunteering_role.update(current_application)
        redirect_to candidate_interface_review_volunteering_path
      else
        render :edit
      end
    end

  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end

    def volunteering_role_params
      params.require(:candidate_interface_volunteering_role_form)
        .permit(
          :id, :role, :organisation, :details, :working_with_children,
          :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)"
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) }
          .transform_values(&:strip)
    end

    def start_date_field_to_attribute(key)
      case key
      when 'start_date(3i)' then 'start_date_day'
      when 'start_date(2i)' then 'start_date_month'
      when 'start_date(1i)' then 'start_date_year'
      else key
      end
    end

    def end_date_field_to_attribute(key)
      case key
      when 'end_date(3i)' then 'end_date_day'
      when 'end_date(2i)' then 'end_date_month'
      when 'end_date(1i)' then 'end_date_year'
      else key
      end
    end
  end
end
