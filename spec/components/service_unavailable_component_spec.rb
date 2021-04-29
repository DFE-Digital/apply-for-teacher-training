require 'rails_helper'

RSpec.describe ServiceUnavailableComponent do
  subject(:result) { render_inline(ServiceUnavailableComponent.new) }

  it 'renders the page title' do
    expect(result.text).to include('Sorry, the service is unavailable')
  end

  it 'renders the page downtime' do
    expect(result.text).to include('Apply for teacher training service')
  end

  context 'when the hosting environment is sandbox', sandbox: true do
    it 'renders the page title' do
      expect(result.text).to include('Sorry, the sandbox is unavailable')
    end

    it 'renders the page downtime', sandbox: true do
      expect(result.text).to include('Apply for teacher training sandbox')
    end
  end
end
