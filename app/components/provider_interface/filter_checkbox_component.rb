module ProviderInterface
  class FilterCheckboxComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :name, :text, :selected, :heading

    def initialize(name:, text:, selected:, heading:)
      @name = name
      @text = text
      @selected = selected
      @heading = heading
    end
  end
end
