module ProviderInterface
  module Offer
    class ConditionsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: action })
        @wizard.save_state!
      end

      def create
        handle_form_input(action: :new)
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: action })
        @wizard.save_state!
      end

      def update
        handle_form_input(action: :edit)
      end

    private

      def handle_form_input(action:)
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if add_another_condition?
          @wizard.add_empty_condition

          respond_to do |format|
            format.js { render :add_another }
            format.html { redirect_to action: action, anchor: anchor_for_further_condition }
          end
        elsif remove_condition_param.present?
          @wizard.remove_condition(remove_condition_param)
          redirect_to action: action, anchor: anchor_for_further_condition
        else
          submit_form(action: action)
        end
      end

      def remove_condition_param
        params[:remove_condition]&.to_i
      end

      def add_another_condition?
        params[:commit] == 'add_another_condition'
      end

      def attributes_for_wizard
        attributes = conditions_params

        further_conditions = conditions_params.fetch('further_conditions', {}).values.map { |hash| hash['text'] }

        attributes.merge!(further_conditions: further_conditions, current_step: 'conditions')
      end

      def conditions_params
        params.require(:provider_interface_offer_wizard)
              .permit(further_conditions: {}, standard_conditions: [])
      end

      def submit_form(action:)
        if @wizard.valid_for_current_step?
          @wizard.remove_empty_conditions!
          @wizard.save_state!

          redirect_to [action, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          render action
        end
      end

      def anchor_for_further_condition
        if remove_condition_param.present?
          'further-conditions-heading'
        elsif add_another_condition?
          "provider-interface-offer-wizard-further-conditions-#{@wizard.further_conditions.length - 1}-text-field"
        end
      end
    end
  end
end
