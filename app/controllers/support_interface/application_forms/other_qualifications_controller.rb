module SupportInterface
  module ApplicationForms
    class OtherQualificationsController < SupportInterfaceController
      before_action :load_edit_other_qualification_form, only: %i[edit update]

      def edit; end

      def update
        @edit_other_qualification_form.assign_attributes_for_qualification(form_params)
        @edit_other_qualification_form.audit_comment = form_params[:audit_comment]

        if @edit_other_qualification_form.valid?
          @edit_other_qualification_form.save!
          flash[:success] = 'Other qualifications updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def load_edit_other_qualification_form
        @edit_other_qualification_form = EditOtherQualificationForm.new(ApplicationQualification.find(params[:id]))
        @application_form = @edit_other_qualification_form.application_form
      end

      def form_params
        params[:support_interface_application_forms_edit_other_qualification_form]
      end
    end
  end
end
