module ProviderInterface
  module Offer
    class ConditionsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: })
        @wizard.save_state!
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: })
        @wizard.save_state!
      end

      def create
        handle_form_input(action: :new)
      end

      def update
        handle_form_input(action: :edit)
      end

    private

      def handle_form_input(action:)
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if add_another_condition?
          @wizard.add_empty_condition
          redirect_to action:, anchor: anchor_for_further_condition
        elsif remove_condition_param.present?
          @wizard.remove_condition(remove_condition_param)
          redirect_to action:, anchor: anchor_for_further_condition
        else
          submit_form(action:)
        end
      end

      def remove_condition_param
        params[:remove_condition]
      end

      def add_another_condition?
        params[:commit] == 'add_another_condition'
      end

      def attributes_for_wizard
        attrs = conditions_params
        attrs['further_condition_attrs'] = attrs.delete('further_conditions') || {}
        attrs.merge!(current_step: 'conditions')
      end

      def conditions_params
        params
          .expect(
            provider_interface_offer_wizard: [:require_references,
                                              :references_description,
                                              further_conditions: {},
                                              standard_conditions: []],
          )
      end

      def submit_form(action:)
        if @wizard.valid_for_current_step?
          @wizard.remove_empty_conditions!
          @wizard.save_state!

          redirect_to [action, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          track_validation_error(@wizard)
          render action
        end
      end

      def anchor_for_further_condition
        if remove_condition_param.present?
          'further-conditions-heading'
        elsif add_another_condition?
          "provider-interface-offer-wizard-further-conditions-#{@wizard.further_condition_attrs.length - 1}-text-field"
        end
      end
    end
  end
end
