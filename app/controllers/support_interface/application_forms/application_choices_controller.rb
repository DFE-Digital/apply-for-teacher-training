module SupportInterface
  module ApplicationForms
    class ApplicationChoicesController < SupportInterfaceController
      before_action :build_application_form, :build_application_choice
      before_action :redirect_to_application_form_unless_declined_and_flag_active, only: %i[reinstate_offer confirm_reinstate_offer]

      def confirm_reinstate_offer
        @declined_course_choice = ReinstateDeclinedOfferForm.new
      end

      def reinstate_offer
        @declined_course_choice = ReinstateDeclinedOfferForm.new(reinstate_offer_params)

        if @declined_course_choice.save(@application_choice)
          flash[:success] = 'Offer was reinstated'
          redirect_to support_interface_application_form_path(@application_form.id)
        else
          render :confirm_reinstate_offer
        end
      end

      def confirm_revert_rejection
        @form = RevertRejectionForm.new
      end

      def revert_rejection
        @form = RevertRejectionForm.new(revert_rejection_params)

        if @form.save(@application_choice)
          flash[:success] = 'Rejection was reverted'
          redirect_to support_interface_application_form_path(@application_form.id)
        else
          render :confirm_revert_rejection
        end
      end

    private

      def reinstate_offer_params
        params.require(:support_interface_application_forms_reinstate_declined_offer_form).permit(:status, :audit_comment_ticket, :accept_guidance)
      end

      def revert_rejection_params
        params.require(:support_interface_application_forms_revert_rejection_form).permit(:audit_comment_ticket, :accept_guidance)
      end

      def build_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def build_application_choice
        @application_choice = @application_form.application_choices.find(params[:application_choice_id])
      end

      def redirect_to_application_form_unless_declined_and_flag_active
        redirect_to support_interface_application_form_path(@application_form.id) unless FeatureFlag.active?(:support_user_reinstate_offer) && @application_choice.declined?
      end
    end
  end
end
