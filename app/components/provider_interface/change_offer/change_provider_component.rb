module ProviderInterface
  module ChangeOffer
    class ChangeProviderComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :change_offer_form, :application_choice, :providers

      def initialize(change_offer_form:, providers:)
        @change_offer_form = change_offer_form
        @application_choice = change_offer_form.application_choice
        @providers = providers.respond_to?(:order) ? providers.order(:name) : providers

        if @change_offer_form.valid?
          @change_offer_form.step = @change_offer_form.next_step
        end
      end

      def page_title
        if application_choice.offer? && change_offer_form.entry == :provider
          'Change training provider'
        else
          'Select alternative training provider'
        end
      end

      def next_step_url
        request.params[:step] = change_offer_form.step
        request.params
      end

      def next_step_method
        :get
      end
    end
  end
end
