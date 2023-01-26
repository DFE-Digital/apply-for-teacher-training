module ProviderInterface
  module Offer
    class SkeStandardFlowsController < SkeController
      def ske_flow_params
        offer_wizard_params.permit(:ske_required)
      end

      def ske_flow_step
        'ske_standard_flow'
      end
    end
  end
end
