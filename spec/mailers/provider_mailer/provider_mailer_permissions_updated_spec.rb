require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'permissions_updated' do
    context 'with remaining permissions' do
      let(:provider) { create(:provider, name: 'Hogwarts University') }
      let(:permissions_updated_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
      let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
      let(:permissions) { %i[view_safeguarding_information view_diversity_information] }

      let(:email) do
        described_class.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Jane Doe updated your permissions for Hogwarts University - manage teacher training applications',
        'salutation' => 'Dear Princess Fiona',
        'heading' => 'Jane Doe updated your permissions for Hogwarts University.',
        'view safeguarding' => 'view criminal convictions and professional misconduct',
        'view diversity' => 'view sex, disability and ethnicity information',
        'link to applications' => 'http://localhost:3000/provider/applications',
        'footer' => 'Get help, report a problem or give feedback',
      )
    end

    context 'all permissions removed' do
      let(:provider) { create(:provider, name: 'Hogwarts University') }
      let(:permissions_updated_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
      let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
      let(:permissions) { %i[] }

      let(:email) do
        described_class.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Jane Doe updated your permissions for Hogwarts University - manage teacher training applications',
        'salutation' => 'Dear Princess Fiona',
        'heading' => 'Jane Doe updated your permissions for Hogwarts University.',
        'permissions' => 'You only have permission to view applications.',
        'link to applications' => 'http://localhost:3000/provider/applications',
        'footer' => 'Get help, report a problem or give feedback',
      )
    end

    describe 'permissions_updated_by_support' do
      let(:provider) { create(:provider, name: 'Hogwarts University') }
      let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
      let(:permissions) { %i[make_decisions view_safeguarding_information] }

      let(:email) do
        described_class.permissions_updated(provider_user, provider, permissions, nil)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your permissions have been updated for Hogwarts University - manage teacher training applications',
        'salutation' => 'Dear Princess Fiona',
        'heading' => 'Your permissions have been updated for Hogwarts University.',
        'make decisions' => 'make offers and reject application',
        'view safeguarding' => 'view criminal convictions and professional misconduct',
        'link to applications' => 'http://localhost:3000/provider/applications',
        'footer' => 'Get help, report a problem or give feedback',
      )
    end
  end
end
