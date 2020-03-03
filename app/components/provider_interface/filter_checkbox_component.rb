module ProviderInterface
  class FilterCheckboxComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :name, :text, :value, :selected, :heading

    def initialize(name:, text:, value:, selected:, heading:)
      @name = name
      @text = text
      @value = value
      @selected = selected
      @heading = heading
    end
  end
end
