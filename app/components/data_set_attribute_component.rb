class DataSetAttributeComponent < ViewComponent::Base
  include MarkdownHelper

  attr_reader :column_name, :column

  def initialize(column_name:, column:)
    @column_name = column_name
    @column = column
  end

  def type_description
    desc = [column['type']]
    desc << ', ISO 8601 date with time and timezone' if column['format'] == 'date-time'
    desc << ', date YYYY-MM-DD' if column['format'] == 'date'

    if column['type'] == 'string' && column['max_length'].present?
      desc << " (limited to #{column['max_length']} characters)"
    end

    desc.join
  end

  def description
    markdown_to_html(column['description'])
  end

  def has_description?
    column['description']
  end

  def example
    column['example'].is_a?(Array) ? column['example'].join('|').inspect : column['example'].inspect
  end

  def has_example?
    column['example']
  end
end
