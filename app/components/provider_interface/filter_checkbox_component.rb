module ProviderInterface
  class FilterCheckboxComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :name, :text

    def initialize(name:, text:, filter_options:)
      @name = name
      @text = text
      @filter_options = filter_options
    end

    def should_be_checked
      @filter_options.include?(@name) ? "checked" : nil
    end
  end
end
