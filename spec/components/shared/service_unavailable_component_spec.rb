require 'rails_helper'

RSpec.describe ServiceUnavailableComponent do
  subject(:result) { render_inline(described_class.new) }

  it 'renders the page title' do
    expect(result.text).to include('Sorry, the service is unavailable')
  end

  it 'renders details about when the page will be available again' do
    expect(result.text).to include('You’ll be able to use the service from 3pm on Monday 11 October 2021')
  end

  context 'when the hosting environment is sandbox', :sandbox do
    it 'renders the page title' do
      expect(result.text).to include('Sorry, the sandbox is unavailable')
    end
  end
end
