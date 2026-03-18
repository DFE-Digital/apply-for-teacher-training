module CandidateInterface
  class TabsComponent < ApplicationComponent
    attr_reader :tabs

    def initialize(tabs:)
      @tabs = tabs
    end
  end
end
