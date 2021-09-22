require 'rails_helper'

RSpec.describe ServiceUnavailableComponent do
  subject(:result) { render_inline(described_class.new) }

  it 'renders the page title' do
    expect(result.text).to include('Sorry, this service is unavailable')
  end

  context 'when the hosting environment is sandbox', sandbox: true do
    it 'renders the page title' do
      expect(result.text).to include('Sorry, the sandbox is unavailable')
    end
  end
end
