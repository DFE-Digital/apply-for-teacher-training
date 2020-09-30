require 'rails_helper'

RSpec.describe DetailsComponent do
  let(:summary_text) { 'This is a summary text' }
  let(:details_text) { 'This is a details text which will be shown once summary text is clicked' }
  let(:details_text_with_html) { "This is a <span class='safe-html'>details text</span> which will be shown once summary text is clicked" }

  it 'renders summary text' do
    result = render_inline(described_class.new(summary_text: summary_text, details_body: details_text))

    expect(result.css('.govuk-details__summary-text').text).to include('This is a summary text')
  end

  it 'renders plain details text' do
    result = render_inline(described_class.new(summary_text: summary_text, details_body: details_text))

    expect(result.css('.govuk-details__text').text).to include('This is a details text which will be shown once summary text is clicked')
  end

  it 'renders details text with HTML tags correctly' do
    result = render_inline(described_class.new(summary_text: summary_text, details_body: details_text_with_html))

    expect(result.css('.govuk-details__text > .safe-html').text).to include('details text')
  end

  it 'ensures details are not visible by default' do
    result = render_inline(described_class.new(summary_text: summary_text, details_body: details_text))

    expect(result.to_html).to include('<details class="govuk-details" data-module="govuk-details">')
  end

  it 'adds open attribute when `open` argument is true' do
    result = render_inline(described_class.new(summary_text: summary_text, details_body: details_text, open: true))

    expect(result.to_html).to include('<details class="govuk-details" data-module="govuk-details" open>')
  end

  it 'applies additonal css classes' do
    result = render_inline(described_class.new(summary_text: summary_text, details_body: details_text, additional_css_classes: 'govuk-!-margin-top-2'))

    expect(result.to_html).to include('<details class="govuk-details govuk-!-margin-top-2" data-module="govuk-details">')
  end
end
