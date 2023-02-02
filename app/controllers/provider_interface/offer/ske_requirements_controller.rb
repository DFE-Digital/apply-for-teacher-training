module ProviderInterface
  module Offer
    class SkeRequirementsController < SkeController
    private

      def ske_flow_params
        offer_wizard_params.permit(
          :language_ske_not_required,
          ske_conditions_attributes: [
            :language,
            :length,
            :reason,
            required: [],
          ],
        )
      end

      def ske_flow_step
        'ske_requirements'
      end

      def assign_new_attributes
        if language_ske?
          @wizard.ske_conditions = OfferWizard::SKE_LANGUAGES.map do |language|
            SkeCondition.new(language:)
          end
        else
          @wizard.ske_conditions = [SkeCondition.new]
        end
      end
    end
  end
end
