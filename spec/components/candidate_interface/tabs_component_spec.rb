require 'rails_helper'

RSpec.describe CandidateInterface::TabsComponent do
  let(:tabs_component) { described_class.new(tabs:) }
  let(:tabs) do
    [
      Tab.new(text: 'All applications', link: '/all', active?: false),
      Tab.new(text: 'Draft', link: '/draft', active?: true),
    ]
  end

  subject(:result) { render_inline(tabs_component) }

  before do
    stub_const('Tab', Struct.new(:text, :link, :active?, keyword_init: true))
  end

  it 'render all tabs' do
    expect(result.css('.tabs-component-navigation__item').text).to include('All applications', 'Draft')
  end

  it 'renders the active tab' do
    expect(result.css('.tabs-component-navigation__item a').find { |item| item['aria-current'].to_s == 'page' }.text).to eq('Draft')
  end

  it 'renders the tab links' do
    expect(result.css('.tabs-component-navigation__item a').map { |link| link[:href] }).to include('/all', '/draft')
  end
end
