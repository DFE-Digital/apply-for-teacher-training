module CandidateInterface
  class TabsComponent < ViewComponent::Base
    attr_reader :tabs

    def initialize(tabs:)
      @tabs = tabs
    end
  end
end
