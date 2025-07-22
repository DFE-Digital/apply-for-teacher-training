module SupportInterface
  module ApplicationForms
    class ImmigrationRightToWorkController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @right_to_work_or_study_form = ImmigrationRightToWorkForm.build_from_application(@application_form)
      end

      def update
        @right_to_work_or_study_form = ImmigrationRightToWorkForm.new(right_to_work_params)

        if @right_to_work_or_study_form.save(@application_form)
          if @application_form.immigration_status.nil? && @right_to_work_or_study_form.right_to_work_or_study == 'yes'
            redirect_to support_interface_application_form_edit_immigration_status_path(@application_form)
          else
            redirect_to support_interface_application_form_path(@application_form)
          end
        else
          render :edit
        end
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def right_to_work_params
        StripWhitespace.from_hash params.expect(
          support_interface_application_forms_immigration_right_to_work_form: %i[right_to_work_or_study right_to_work_or_study_details audit_comment],
        )
      end
    end
  end
end
