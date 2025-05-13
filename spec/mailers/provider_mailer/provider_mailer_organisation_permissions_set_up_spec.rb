require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'organisation_permissions_set_up' do
    let(:training_provider) { build_stubbed(:provider, id: 123,  name: 'University of Purley') }
    let(:ratifying_provider) { build_stubbed(:provider, id: 345, name: 'University of Croydon') }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', providers: [training_provider]) }
    let(:permissions) do
      build_stubbed(
        :provider_relationship_permissions,
        ratifying_provider:,
        training_provider:,
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
      )
    end
    let(:email) { described_class.organisation_permissions_set_up(provider_user, training_provider, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon set up organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'heading' => 'University of Croydon set up organisation permissions for courses you run with them',
      'make offers' => /Send offers, invitations and rejections:\s+- University of Purley/,
      'view safeguarding' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'view diversity' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'link to manage organisation permissions' => '/provider/organisation-settings/organisations/123/organisation-permissions',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end
end
