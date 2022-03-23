RSpec::Matchers.define :summarise do |expected|
  match do |_actual|
    if expected[:action]
      key_html && value_html && value_text == expected[:value] && action_link && action_link[:href] == expected[:action][:href]
    else
      key_html && value_html && value_text == expected[:value]
    end
  end

  failure_message do |actual|
    if !key_html
      "Could not find the key ‘#{expected[:key]}’ within\n\n #{actual}"
    elsif !value_html
      "Could not find a <dd class=\"govuk-summary-list__value\"> element within HTML: \n#{row_html.native.to_html}"
    elsif value_text != expected[:text]
      "Expected ‘#{expected[:key]}’ value to be ‘#{expected[:value]}’ but was ‘#{value_text}’"
    elsif !action_link
      "Could not find the link ‘#{expected[:action][:text]}’ within HTML: \n#{row_html.native.to_html}"
    else
      "Expected link href to be #{expected[:action][:href]}, was #{action_link[:href]}"
    end
  end

  def html
    @html ||= Capybara::Node::Simple.new(actual)
  end

  def key_html
    @key_html ||= html.all('dt.govuk-summary-list__key', exact_text: expected[:key]).first
  end

  def row_html
    @row_html ||= key_html.ancestor('.govuk-summary-list__row')
  end

  def value_html
    @value_html ||= row_html.all('dd.govuk-summary-list__value').first
  end

  def value_text
    @value_text ||= value_html.text(normalize_ws: true)
  end

  def action_link
    @action_link ||= row_html.all(:link, exact_text: expected[:action][:text]).first
  end
end
