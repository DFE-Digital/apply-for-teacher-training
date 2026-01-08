module CandidateInterface
  class TabsComponent < BaseComponent
    attr_reader :tabs

    def initialize(tabs:)
      @tabs = tabs
    end
  end
end
