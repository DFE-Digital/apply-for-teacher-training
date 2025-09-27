module Publications
  class DataTableComponent < ViewComponent::Base
    attr_reader :caption, :title, :data

    def initialize(caption:, title:, data:, key: title)
      @caption = caption
      @title = title
      @data = data
      @key = key
    end

    def tab_names
      data.keys
    end

    def dom_id(tab_name)
      "#{key.parameterize}-#{tab_name}".downcase.dasherize
    end

  private

    attr_reader :key
  end
end
