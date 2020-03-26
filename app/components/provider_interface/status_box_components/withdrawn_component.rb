module ProviderInterface
  module StatusBoxComponents
    class WithdrawnComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def render?
        (application_choice.withdrawn? && !application_choice.offer_withdrawn_at) || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Application withdrawn',
            value: application_choice.withdrawn_at.to_s(:govuk_date),
          },
        ]
      end
    end
  end
end
