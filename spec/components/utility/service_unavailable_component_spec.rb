require 'rails_helper'

RSpec.describe ServiceUnavailableComponent do
  subject(:result) { render_inline(described_class.new) }

  it 'renders the page title' do
    expect(result.text).to include('Sorry, this service is unavailable')
  end

  it 'renders the page downtime' do
    expect(result.text).to include('use this service')
  end

  context 'when the hosting environment is sandbox', sandbox: true do
    it 'renders the page title' do
      expect(result.text).to include('Sorry, the sandbox is unavailable')
    end

    it 'renders the page downtime', sandbox: true do
      expect(result.text).to include('use the sandbox')
    end
  end
end
