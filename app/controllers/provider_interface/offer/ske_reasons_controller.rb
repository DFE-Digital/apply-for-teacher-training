module ProviderInterface
  module Offer
    class SkeReasonsController < SkeController
      def ske_flow_params
        offer_wizard_params.permit(:ske_reason)
      end

      def ske_flow_step
        'ske_reason'
      end
    end
  end
end
