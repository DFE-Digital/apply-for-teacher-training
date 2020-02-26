module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by, :filter_options

    def initialize(page_state:)
      @sort_order = page_state.sort_order
      @current_sort_by = page_state.sort_by
      @filter_options = page_state.filter_options
    end

    def status_filter_checkbox_names_text
      [
        ["pending_conditions", "Accepted"], ["recruited", "Conditions met"],
        ["declined", "Declined"], ["awaiting_provider_decision", "New"],
        ["offer", "Offered"], ["rejected", "Rejected"],
        ["withdrawn", "Application withdrawn"], ["offer_withdrawn", "Offer withdrawn"]
      ]
    end
  end
end
