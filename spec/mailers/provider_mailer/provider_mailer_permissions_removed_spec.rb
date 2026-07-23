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
      'Jane Doe has removed your access to Manage - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'removed_access' => 'Jane Doe has removed your access to Manage.',
      'no_longer_able' => 'You are no longer able to manage teacher training applications for Hogwarts University.',
      'manage_again' => 'If you want to use Manage again',
      'contact_person' => 'You will need to contact the person who removed your access.',
      'contact_us' => 'Contact us',
      'any_questions' => 'If you have any questions, please contact us at [becomingateacher@digital.education.gov.uk](mailto:becomingateacher@digital.education.gov.uk).',
      'regard' => 'Regards,',
      'becoming_a_teacher_team' => 'Becoming a Teacher team',
    )
  end

  describe 'permissions_removed_by_support' do
    let(:provider) { create(:provider, name: 'Hogwarts University') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions_removed_by_user) { nil }

    it_behaves_like(
      'a mail with subject and content',
      'Your access to your Manage account has been removed - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'access_removed' => 'Your access to your Manage account has been removed.',
      'not_signed_in' => 'This is because your account had not been signed in to for 12 months.',
      'no_longer_able' => 'You are no longer able to manage teacher training applications for Hogwarts University.',
      'manage_again' => 'If you want to use Manage again',
      'access_back' => 'You will need to contact us at [becomingateacher@digital.education.gov.uk](mailto:becomingateacher@digital.education.gov.uk) to get your access back.',
      'contact_us' => 'Contact us',
      'any_questions' => 'If you have any questions, please contact us at [becomingateacher@digital.education.gov.uk](mailto:becomingateacher@digital.education.gov.uk).',
      'regard' => 'Regards,',
      'becoming_a_teacher_team' => 'Becoming a Teacher team',
    )
  end
end
