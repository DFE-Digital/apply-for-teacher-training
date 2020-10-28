require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchesTableComponent do
  let(:today) { Time.zone.local(2020, 1, 7, 12, 0, 0) }
  let(:ucas_match) { create(:ucas_match, matching_state: 'new_match') }

  around do |example|
    Timecop.freeze(today) do
      example.run
    end
  end

  it 'renders the status' do
    expect(render_result.css('.govuk-tag').first.text.strip).to eq('New match')
  end

  it 'renders candidates email address' do
    expect(render_result.text).to include(ucas_match.candidate.email_address)
  end

  it 'renders last update' do
    expect(render_result.text).to include('7 January 2020')
  end

  def render_result
    render_inline(described_class.new(matches: [ucas_match]))
  end
end
