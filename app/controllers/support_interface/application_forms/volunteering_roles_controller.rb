module SupportInterface
  module ApplicationForms
    class VolunteeringRolesController < SupportInterfaceController
      before_action :build_application_form

      def edit
        @volunteering_role_form = VolunteeringRoleForm.build_from_experience(volunteering_role)
      end

      def update
        @volunteering_role_form = VolunteeringRoleForm.new(volunteering_role_form_params)

        if @volunteering_role_form.update(@application_form)
          flash[:success] = 'Volunteering role updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def build_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def volunteering_role
        @application_form
          .application_volunteering_experiences
          .find(volunteering_role_params[:volunteering_role_id])
      end

      def volunteering_role_params
        params.permit(:volunteering_role_id)
      end

      def volunteering_role_form_params
        StripWhitespace.from_hash(
          params
                .expect(
                  support_interface_application_forms_volunteering_role_form: %i[id
                                                                                 role
                                                                                 organisation
                                                                                 details
                                                                                 working_with_children
                                                                                 start_date(3i)
                                                                                 start_date(2i)
                                                                                 start_date(1i)
                                                                                 start_date_unknown
                                                                                 currently_working
                                                                                 end_date(3i)
                                                                                 end_date(2i)
                                                                                 end_date(1i)
                                                                                 end_date_unknown
                                                                                 audit_comment],
                )
                .transform_keys { |key| start_date_field_to_attribute(key) }
                .transform_keys { |key| end_date_field_to_attribute(key) },
        )
      end
    end
  end
end
