require 'rails_helper'

RSpec.describe ProviderMailer do
  let(:email) do
    described_class.permissions_removed(provider_user, provider, permissions_removed_by_user)
  end

  describe 'permissions_removed' do
    let(:provider) { create(:provider, name: 'Hogwarts University') }
    let(:permissions_removed_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe has removed you from Hogwarts University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe has removed you from Hogwarts University. You can no longer manage their teacher training applications.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_removed_by_support' do
    let(:provider) { create(:provider, name: 'Hogwarts University') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions_removed_by_user) { nil }

    it_behaves_like(
      'a mail with subject and content',
      'You have been removed from Hogwarts University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'You have been removed from Hogwarts University. You can no longer manage their teacher training applications.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end
end
