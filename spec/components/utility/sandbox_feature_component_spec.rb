require 'rails_helper'

RSpec.describe SandboxFeatureComponent, type: :component do
  it 'renders with status tag and a description' do
    result = render_inline(described_class.new(description: 'Secret sandbox feature'))

    expect(result.css('.govuk-tag').text).to include('Sandbox feature')
    expect(result.text).to include('Secret sandbox feature')
  end
end
