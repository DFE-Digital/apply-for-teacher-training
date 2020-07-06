require 'rails_helper'

RSpec.describe WarningTextComponent do
  let(:text) { 'We’ll tell the candidate' }

  it 'renders the warning text' do
    result = render_inline(described_class.new(text: text))

    expect(result.css('.govuk-warning-text__text').text).to include('We’ll tell the candidate')
  end

  it 'renders the warning icon' do
    result = render_inline(described_class.new(text: text))

    expect(result.css('.govuk-warning-text__icon')).to be_present
  end
end
