module ProviderInterface
  class ToggleFilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :filter_visible, :additional_params

    def initialize(filter_visible:, additional_params:)
      @filter_visible = filter_visible
      @additional_params = additional_params
    end

    def toggle_filter
      @filter_visible.eql?('true') ? 'false' : 'true'
    end

    def toggle_button_text
      @filter_visible.eql?('true') ? 'Hide filter' : 'Show filter'
    end
  end
end
