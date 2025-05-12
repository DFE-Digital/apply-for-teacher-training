require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'permissions_granted_by_support' do
    let(:provider) { create(:provider, name: 'Hogwarts University') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[make_decisions view_diversity_information] }

    let(:email) do
      described_class.permissions_granted(provider_user, provider, permissions, nil)
    end

    it_behaves_like(
      'a mail with subject and content',
      'You have been added to Hogwarts University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'You have been added to Hogwarts University. You can now manage their teacher training applications.',
      'make decisions' => 'send offers, invitations and rejections',
      'view diversity' => 'view sex, disability and ethnicity information',
      'dsi info' => 'If you do not have a DfE Sign-in account, you should have received an email with instructions from dfe.signin@education.gov.uk.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end
end
