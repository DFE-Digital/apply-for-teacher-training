require 'rails_helper'

RSpec.describe ProviderInterface::WithdrawnTagOverrideComponent do
  it 'renders "Withdrawn" instead of "Application Withdrawn" for withdrawn status' do
    application_choice = build_stubbed(:application_choice, status: :withdrawn)

    result = render_inline described_class.new(application_choice:)

    expect(result.text).to include('Withdrawn')
    expect(result.text).not_to include('Application Withdrawn')
  end

  it 'delegates to the original component behavior for other statuses' do
    application_choice = build_stubbed(:application_choice, status: :recruited)

    result = render_inline described_class.new(application_choice:)

    expect(result.text).to include('Recruited')
  end
end
