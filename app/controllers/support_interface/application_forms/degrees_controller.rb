module SupportInterface
  module ApplicationForms
    class DegreesController < SupportInterfaceController
      def edit
        @degree_form = EditDegreeForm.new(
          ApplicationQualification.find(params[:degree_id]),
        )
      end

      def update
        @degree_form = EditDegreeForm.new(
          ApplicationQualification.find(params[:degree_id]),
        )

        @degree_form.assign_attributes(edit_application_params)
        if @degree_form.valid?
          @degree_form.save!
          flash[:success] = 'Degree updated'
          redirect_to support_interface_application_form_path(@degree_form.application_form)
        else
          render :edit
        end
      end

    private

      def edit_application_params
        params.require(
          :support_interface_application_forms_edit_degree_form,
        ).permit(:start_year, :award_year, :audit_comment)
      end
    end
  end
end
