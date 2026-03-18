module ProviderInterface
  module StatusBoxComponents
    class AwaitingProviderDecisionComponent < ApplicationComponent
      include ViewHelper

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        false
      end
    end
  end
end
