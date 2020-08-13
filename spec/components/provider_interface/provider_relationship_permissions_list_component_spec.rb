require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsListComponent do
  let(:ratifying_provider) { build_stubbed(:provider) }
  let(:training_provider) { build_stubbed(:provider) }

  let(:permissions_model) do
    build_stubbed(
      :provider_relationship_permissions,
      ratifying_provider: ratifying_provider,
      training_provider: training_provider,
    )
  end

  let(:wizard) { instance_double(ProviderInterface::ProviderRelationshipPermissionsSetupWizard) }

  before do
    allow(wizard).to receive(:permissions_for_relationship)
      .with(permissions_model.id)
      .and_return('make_decisions' => %w[training ratifying], 'view_safeguarding_information' => %w[training], 'view_diversity_information' => %w[training])
  end

  it 'renders provider relationship permissions in a summary list' do
    result = render_inline(described_class.new(permissions_model: permissions_model, wizard: wizard))

    expect(result.css('.govuk-summary-list__key')[0].text).to include('Which organisations can make decisions?')
    expect(result.css('.govuk-summary-list__value')[0].text).to include(training_provider.name)
    expect(result.css('.govuk-summary-list__value')[0].text).to include(ratifying_provider.name)
    expect(result.css('.govuk-summary-list__actions')[0].text).to include("Change which organisations can make decisions for courses run by #{training_provider.name} and ratified by #{ratifying_provider.name}")

    expect(result.css('.govuk-summary-list__key')[1].text).to include('Which organisations can view safeguarding information?')
    expect(result.css('.govuk-summary-list__value')[1].text).to include(training_provider.name)
    expect(result.css('.govuk-summary-list__value')[1].text).not_to include(ratifying_provider.name)
    expect(result.css('.govuk-summary-list__actions')[1].text).to include("Change which organisations can view safeguarding information for courses run by #{training_provider.name} and ratified by #{ratifying_provider.name}")

    expect(result.css('.govuk-summary-list__key')[2].text).to include('Which organisations can view diversity information?')
    expect(result.css('.govuk-summary-list__value')[2].text).to include(training_provider.name)
    expect(result.css('.govuk-summary-list__value')[2].text).not_to include(ratifying_provider.name)
    expect(result.css('.govuk-summary-list__actions')[2].text).to include("Change which organisations can view diversity information for courses run by #{training_provider.name} and ratified by #{ratifying_provider.name}")
  end
end
