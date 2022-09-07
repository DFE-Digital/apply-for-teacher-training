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

  def actions(row)
    defined_action = row[:action] || row[:actions]

    return defined_action if defined_action.present?

    { href: '' } if any_rows_with_actions?
  end

  def html_attributes(row)
    row[:html_attributes] || {}
  end

private

  attr_reader :rows

  def transform_hash(row_hash)
    row_hash.map do |key, value|
      {
        key:,
        value:,
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

  def any_rows_with_actions?
    rows.any? { |row| (row[:action] || row[:actions]).present? }
  end

  def options
    opts = {}
    if !any_rows_with_actions?
      opts[:actions] = false
    end
    opts
  end
end
