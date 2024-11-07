require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'permissions_granted' do
    let(:provider) { create(:provider, name: 'Hogwarts University') }
    let(:permissions_granted_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[make_decisions view_safeguarding_information view_diversity_information] }

    let(:email) do
      described_class.permissions_granted(provider_user, provider, permissions, permissions_granted_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe added you to Hogwarts University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe added you to Hogwarts University. You can now manage their applications.',
      'make decisions' => 'make offers and reject application',
      'view safeguarding' => 'view criminal convictions and professional misconduct',
      'view diversity' => 'view sex, disability and ethnicity information',
      'dsi info' => 'If you do not have a DfE Sign-in account, you should have received an email with instructions from dfe.signin@education.gov.uk.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end
end
