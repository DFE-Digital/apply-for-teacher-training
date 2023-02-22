module ProviderInterface
  module Offer
    class SkeRequirementsController < SkeController
      def create
        super do |wizard|
          wizard.ske_conditions = build_ske_conditions

          if no_options_selected?
            wizard.errors.add(:base, :blank)
          elsif no_and_languages_selected?
            wizard.errors.add(:base, :no_and_languages_selected)
          end
        end
      end

    private

      def ske_flow_params
        {}
      end

      def ske_flow_step
        'ske_requirements'
      end

      def build_ske_conditions
        if ske_required?
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
        selected_options - ['no']
      end

      def selected_options
        Array(offer_wizard_params[:ske_languages]).compact_blank
      end

      def no_options_selected?
        if language_ske?
          selected_options.count.zero?
        else
          offer_wizard_params[:ske_required].blank?
        end
      end

      def no_and_languages_selected?
        selected_options.count > 1 && selected_options.include?('no')
      end
    end
  end
end
