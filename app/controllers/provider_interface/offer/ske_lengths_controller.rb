module ProviderInterface
  module Offer
    class SkeLengthsController < SkeController
      def ske_flow_params
        if offer_wizard_params[:ske_language_length_1].present?
          offer_wizard_params.permit(:ske_language_length_1, :ske_language_length_2)
        else
          offer_wizard_params.permit(:ske_length)
        end
      end

      def ske_flow_step
        'ske_length'
      end
    end
  end
end
