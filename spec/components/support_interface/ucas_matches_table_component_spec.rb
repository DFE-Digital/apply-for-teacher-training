require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchesTableComponent do
  let(:ucas_match) { create(:ucas_match) }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  it 'renders the status' do
    expect(render_result.css('.govuk-tag').first.text.strip).to eq('No action taken')
  end

  it 'renders candidates email address' do
    expect(render_result.text).to include(ucas_match.candidate.email_address)
  end

  it 'renders last update' do
    expect(render_result.text).to include(Date.current.to_s(:govuk_date))
  end

  def render_result
    render_inline(described_class.new(matches: [ucas_match]))
  end
end
