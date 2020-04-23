module ProviderInterface
  class ToggleFilterComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :filter_visible, :params_for_current_state

    def initialize(filter_visible:, params_for_current_state:)
      @filter_visible = filter_visible
      @params_for_current_state = params_for_current_state
    end

    def toggle_filter
      @filter_visible.eql?('true') ? 'false' : 'true'
    end

    def toggle_button_text
      @filter_visible.eql?('true') ? 'Hide filter' : 'Show filter'
    end
  end
end
