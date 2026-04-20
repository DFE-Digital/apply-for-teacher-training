module SupportInterface
  module ApplicationChoices
    class VisaExplanationsController < SupportInterfaceController
      before_action :set_application_choice

      def edit
        @form = VisaExplanationForm.new(@application_choice)
      end

      def update
        @form = VisaExplanationForm.new(@application_choice)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to support_interface_application_form_path(@application_choice.application_form)
        else
          render :edit
        end
      end

    private

      def set_application_choice
        @application_choice = ApplicationChoice.find(params.require(:application_choice_id))
      end

      def request_params
        params.expect(
          support_interface_application_choices_visa_explanation_form: %i[
            visa_explanation
            visa_explanation_details
            audit_comment
          ],
        )
      end
    end
  end
end
