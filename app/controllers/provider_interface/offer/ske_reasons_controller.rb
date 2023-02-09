module ProviderInterface
  module Offer
    class SkeReasonsController < SkeController
      def assign_new_attributes
        #        @wizard.ske_conditions.select! { |ske_reason| @wizard.ske_languages.include?(ske_reason.language) }
        #       @wizard.ske_languages.each do |language, hash|
        #         @wizard.ske_reasons << SkeReason.new(language:) unless @wizard.ske_reasons.map(&:language).include?(language)
        #       end
      end

      def ske_flow_params
        if offer_wizard_params[:ske_reason].present?
          offer_wizard_params.permit(:ske_reason)
        else
          offer_wizard_params.permit(ske_reasons_attributes: {})
        end
      end

      def ske_flow_step
        'ske_reason'
      end
    end
  end
end
