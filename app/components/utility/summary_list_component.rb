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
      row[:value]
    else
      simple_format(row[:value], class: 'govuk-body')
    end
  end

  def action(row)
    if row[:action]
      row[:action]['classes'] = 'govuk-!-display-none-print'
      row[:action]
    elsif row[:actions]
      # TODO: Add multiple actions using govuk-components method
      # https://github.com/DFE-Digital/govuk-components/issues/218
      links = row[:actions].map do |action|
        govuk_link_to(action[:href], class: 'govuk-!-display-none-print') do
          "#{action[:text]}<span class=\"govuk-visually-hidden\"> #{action[:visually_hidden_text]}</span>".html_safe
        end
      end
      {
        text: links.join('<br>').html_safe,
        href: '#',
      }
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
    markup = '<ul class="govuk-list govuk-list--bullet">'.html_safe
    list.map do |list_item|
      markup << '<li>'.html_safe << list_item << '</li>'.html_safe
    end
    markup + '</ul>'.html_safe
  end

  def format_list_as_paragraphs(list)
    list.map { |s| "<p class=\"govuk-body\">#{ERB::Util.html_escape(s)}</p>" }.join.html_safe
  end
end
