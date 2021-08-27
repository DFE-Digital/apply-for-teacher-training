class SummaryListComponent < ViewComponent::Base
  include ViewHelper

  def initialize(rows:)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows
  end

  def value(row)
    if row[:value].is_a?(Array)
      if row[:bulleted_format]
        format_list_with_bullets(row[:value])
      elsif row[:paragraph_format]
        format_list_as_paragraphs(row[:value])
      else
        row[:value].map { |s| ERB::Util.html_escape(s) }.join('<br>').html_safe
      end
    elsif row[:value].html_safe?
      row[:value].to_s
    else
      simple_format(row[:value], class: 'govuk-body')
    end
  end

  def html_attributes(row)
    row[:html_attributes] || {}
  end

private

  attr_reader :rows

  def transform_hash(row_hash)
    row_hash.map do |key, value|
      {
        key: key,
        value: value,
      }
    end
  end

  def format_list_with_bullets(list)
    tag.ul(class: 'govuk-list govuk-list--bullet') do
      safe_join(list.map { |item| tag.li(item) })
    end
  end

  def format_list_as_paragraphs(list)
    safe_join(list.map { |s| tag.p(class: 'govuk-body') { ERB::Util.html_escape(s) } })
  end
end
