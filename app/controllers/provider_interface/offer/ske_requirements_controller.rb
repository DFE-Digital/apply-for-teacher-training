module ProviderInterface
  module Offer
    class SkeRequirementsController < SkeController
    private

      def ske_flow_params
        offer_wizard_params.permit(
          :ske_required,
          ske_languages: [],
        )
      end

      def ske_flow_step
        'ske_requirements'
      end

      def assign_create_attributes
         @wizard.ske_conditions = if ske_required?
                                    if language_ske?
                                      required_languages.map { |language| SkeCondition.new(language:) }
                                    else
                                      [SkeCondition.new]
                                    end
                                  else
                                    []
                                  end
      end

      def ske_required?
        offer_wizard_params[:ske_required] == 'true' || required_languages.any?
      end

      def required_languages
        Array(offer_wizard_params[:ske_languages]).compact_blank - ['no']
      end
    end
  end
end
