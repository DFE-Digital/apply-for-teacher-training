module ProviderInterface
  module Offer
    class SkeLengthsController < SkeController
      def ske_flow_params
        offer_wizard_params.permit(
          ske_conditions_attributes: %i[
            language
            length
          ],
        )
      end

      def ske_flow_step
        'ske_length'
      end
    end
  end
end
