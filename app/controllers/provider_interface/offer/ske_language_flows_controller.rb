module ProviderInterface
  module Offer
    class SkeLanguageFlowsController < SkeController
      def ske_flow_params
        offer_wizard_params.permit(ske_language_required: [])
      end

      def ske_flow_step
        'ske_language_flow'
      end
    end
  end
end
