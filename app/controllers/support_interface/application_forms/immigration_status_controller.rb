module SupportInterface
  module ApplicationForms
    class ImmigrationStatusController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @immigration_status_form = ImmigrationStatusForm.build_from_application(@application_form)
      end

      def update
        @immigration_status_form = ImmigrationStatusForm.new(immigration_status_params.merge(nationalities: @application_form.nationalities))

        if @immigration_status_form.save(@application_form)
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def immigration_status_params
        params.require(
          :support_interface_application_forms_immigration_status_form,
        ).permit(:immigration_status, :right_to_work_or_study_details, :audit_comment)
      end
    end
  end
end
