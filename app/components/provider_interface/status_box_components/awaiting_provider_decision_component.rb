module ProviderInterface
  module StatusBoxComponents
    class AwaitingProviderDecisionComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(args)
        @application_choice = args[:application_choice]
      end

      def render?
        false
      end
    end
  end
end
