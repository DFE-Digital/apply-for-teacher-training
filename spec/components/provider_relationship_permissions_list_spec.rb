require 'rails_helper'

RSpec.describe ProviderRelationshipPermissionsList do
  let(:training_provider) { create(:provider) }
  let(:ratifiying_provider) { create(:provider) }
  let(:provider_relationship_permissions) do
    create(:provider_relationship_permissions,
           training_provider: training_provider,
           ratifying_provider: ratifiying_provider,
           training_provider_can_make_decisions: true,
           training_provider_can_view_safeguarding_information: true)
  end

  it 'does not render view only organisations if both providers have at least one permission' do
    provider_relationship_permissions =
      create(:provider_relationship_permissions,
             training_provider_can_make_decisions: true,
             ratifying_provider_can_view_safeguarding_information: true)

    result = render_inline(described_class.new(provider_relationship_permissions))
    expect(result.css('.govuk-body').text).not_to include('The following organisation(s) can only view applications')
  end

  it 'renders organisations who can make decisions' do
    result = render_inline(described_class.new(provider_relationship_permissions))

    expect(result.css('.govuk-body').first.text).to include('The following organisation(s) can make decisions:')
    expect(result.css('.govuk-list').first.text).to include(training_provider.name.to_s)
    expect(result.css('.govuk-list').first.text).not_to include(ratifiying_provider.name.to_s)
  end

  it 'renders organisations who can view safeguarding information' do
    result = render_inline(described_class.new(provider_relationship_permissions))

    expect(result.css('.govuk-body')[1].text).to include('The following organisation(s) can see safeguarding information:')
    expect(result.css('.govuk-list')[1].text).to include(training_provider.name.to_s)
    expect(result.css('.govuk-list')[1].text).not_to include(ratifiying_provider.name.to_s)
  end

  it 'renders organisations who can only view applications' do
    result = render_inline(described_class.new(provider_relationship_permissions))

    expect(result.css('.govuk-body')[2].text).to include('The following organisation(s) can only view applications:')
    expect(result.css('.govuk-list')[2].text).not_to include(training_provider.name.to_s)
    expect(result.css('.govuk-list')[2].text).to include(ratifiying_provider.name.to_s)
  end
end
