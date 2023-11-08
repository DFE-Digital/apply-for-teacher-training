# frozen_string_literal: true

module Publications
  class DataTableComponent < ViewComponent::Base
    attr_reader :caption, :title, :data

    def initialize(caption:, title:, data:)
      @caption = caption
      @title = title
      @data = data
    end

    def tab_names
      data.keys
    end

    def dom_id(title, tab_name)
      "#{title}-#{tab_name}".downcase.dasherize
    end
  end
end
