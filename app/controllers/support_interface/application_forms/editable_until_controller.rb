module SupportInterface
  module ApplicationForms
    class EditableUntilController < SupportInterfaceController
      def edit
        @application_form = ApplicationForm.find(params[:application_form_id])
        @form = EditableUntilForm.new(application_form: @application_form)
      end

      def update
        @application_form = ApplicationForm.find(params[:application_form_id])
        @form = EditableUntilForm.new(editable_until_params.merge(application_form: @application_form))

        if @form.save
          flash[:success] = 'Application form updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit
        end
      end

    private

      def editable_until_params
        params.require(:support_interface_editable_until_form).permit!
      end
    end
  end
end
