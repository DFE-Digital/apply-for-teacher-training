module ProviderInterface
  class StatusBoxComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def application_status
      application_choice.status
    end

    def status_box_component_to_render
      "ProviderInterface::StatusBoxComponents::#{application_status.camelize}Component".constantize
    end

    # Should never happpen, but who knows
    class ComponentMismatchError < StandardError; end
  end
end
