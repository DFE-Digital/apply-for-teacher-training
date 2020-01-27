module SupportInterface
  class StateExplanationComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :state

    def initialize(state:)
      @state = state
    end

    def state_name
      state.name.to_s
    end
  end
end
