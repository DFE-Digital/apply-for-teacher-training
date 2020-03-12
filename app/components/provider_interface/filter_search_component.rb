module ProviderInterface
  class FilterSearchComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :name, :type, :heading

    def initialize(name:, type:, heading:)
      @name = name
      @type = type
      @heading = heading
    end
  end
end
