module ProviderInterface
  module StatusBoxComponents
    class WithdrawnComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def render?
        false
      end
    end
  end
end
