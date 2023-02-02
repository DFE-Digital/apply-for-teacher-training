module ProviderInterface
  module Offer
    class SkeReasonsController < SkeController
      def ske_flow_params
        if offer_wizard_params[:ske_language_reason_1].present?
          offer_wizard_params.permit(:ske_language_reason_1, :ske_language_reason_2)
        else
          offer_wizard_params.permit(:ske_reason)
        end
      end

      def ske_flow_step
        'ske_reason'
      end
    end
  end
end
