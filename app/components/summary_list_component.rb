class SummaryListComponent < ViewComponent::Base
  include ViewHelper

  def initialize(rows:)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows
  end

  def value(row)
    if row[:value].is_a?(Array)
      row[:value].map { |s| ERB::Util.html_escape(s) }.join('<br>').html_safe
    elsif row[:value].html_safe?
      row[:value]
    else
      simple_format(row[:value], class: 'govuk-body')
    end
  end

  def action(row)
    if row[:change_path]
      govuk_link_to(row[:change_path], class: 'govuk-!-display-none-print') do
        "Change<span class=\"govuk-visually-hidden\"> #{row[:action]}</span>".html_safe
      end
    elsif row[:action_path]
      govuk_link_to(row[:action], row[:action_path], class: 'govuk-!-display-none-print')
    elsif row[:actions]
      links = row[:actions].map do |action|
        govuk_link_to(action[:path], class: 'govuk-!-display-none-print') do
          "#{action[:verb]}<span class=\"govuk-visually-hidden\"> #{action[:object]}</span>".html_safe
        end
      end
      links.join('<br>').html_safe
    elsif any_row_has_action_span?
      tag.dd(class: 'govuk-summary-list__actions')
    end
  end

  def html_attributes(row)
    if row[:data_qa]
      { 'data-qa' => row[:data_qa] }
    else
      {}
    end
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

  def any_row_has_action_span?
    rows.select { |row| row.key?(:action) }.any?
  end
end
