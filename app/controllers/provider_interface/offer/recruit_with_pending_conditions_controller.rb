module ProviderInterface
  module Offer
    class RecruitWithPendingConditionsController < ProviderInterfaceController
      before_action :set_application_choice
      before_action :confirm_application_can_be_recruited_with_pending_conditions

      def new
      end

      def create
      end

    private

      def confirm_application_can_be_recruited_with_pending_conditions
        return if CanRecruitWithPendingConditions.new(application_choice: @application_choice).call

        redirect_to(provider_interface_application_choice_path(@application_choice))
      end
    end
  end
end
