module SupportInterface
  module ApplicationForms
    class ReferencesController < SupportInterfaceController
      def edit_reference_details
        @details_form = EditReferenceDetailsForm.build_from_reference(reference)
      end

      def update_reference_details
        @details_form = EditReferenceDetailsForm.new(edit_reference_details_params)

        if @details_form.save(reference)
          flash[:success] = 'Reference updated'
          redirect_to support_interface_application_form_path(reference.application_form)
        else
          render :edit_reference_details
        end
      end

      def edit_reference_feedback
        @feedback_form = EditReferenceFeedbackForm.build_from_reference(reference)
      end

      def update_reference_feedback
        @feedback_form = EditReferenceFeedbackForm.new(edit_reference_feedback_params)

        if @feedback_form.save(reference)
          SubmitReference.new(reference:, send_emails:, selected: reference.selected?).save!
          flash[:success] = 'Reference updated'
          redirect_to support_interface_application_form_path(@reference.application_form)
        else
          render :edit_reference_feedback
        end
      end

    private

      def edit_reference_details_params
        params.expect(support_interface_application_forms_edit_reference_details_form: %i[name email_address relationship audit_comment])
      end

      def edit_reference_feedback_params
        params.expect(support_interface_application_forms_edit_reference_feedback_form: %i[feedback audit_comment send_emails])
      end

      def send_emails
        edit_reference_feedback_params[:send_emails] == 'true'
      end

      def reference
        @reference = ApplicationReference.find(params[:reference_id])
      end
    end
  end
end
