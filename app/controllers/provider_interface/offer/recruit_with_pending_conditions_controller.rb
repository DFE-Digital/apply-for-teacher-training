module ProviderInterface
  module Offer
    class RecruitWithPendingConditionsController < ProviderInterfaceController
      before_action :set_application_choice
      before_action :confirm_application_can_be_recruited_with_pending_conditions

      def new
        @recruit_with_pending_conditions_form =
          ProviderInterface::RecruitWithPendingConditionsForm.new(
            application_choice: @application_choice,
          )
      end

      def create
        @recruit_with_pending_conditions_form =
          ProviderInterface::RecruitWithPendingConditionsForm.new(
            create_params,
          )

        if @recruit_with_pending_conditions_form.save
          flash[:success] = 'Applicant recruited with conditions pending' 
          redirect_to(
            provider_interface_application_choice_offer_path(application_choice_id: @application_choice.id),
          )
        else
          render :new
        end
      end

    private

      def confirm_application_can_be_recruited_with_pending_conditions
        return if CanRecruitWithPendingConditions.new(application_choice: @application_choice).call

        redirect_to(provider_interface_application_choice_path(@application_choice))
      end

      def create_params
        form_params = params.permit(provider_interface_recruit_with_pending_conditions_form: :confirmation)[:provider_interface_recruit_with_pending_conditions_form]
        (form_params || {}).merge(application_choice: @application_choice)
      end
    end
  end
end
