require "rails_helper"

RSpec.describe GovUkStartButtonComponent, type: :component do
  it 'renders with button with an icon and specified link and title' do
    render_result = render_inline(described_class.new(title: "Button", href: "www.example.com"))

    expect(render_result.css('a').attr('href').value).to eq 'www.example.com'
    expect(render_result.text).to include('Button')
    expect(render_result.search('svg').first[:class]).to include('govuk-button__start-icon')
  end
end
