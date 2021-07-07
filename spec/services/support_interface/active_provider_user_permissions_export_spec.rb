require 'rails_helper'

RSpec.describe SupportInterface::ActiveProviderUserPermissionsExport do
  around do |example|
    Timecop.freeze(Time.zone.now.change(usec: 0)) do
      example.run
    end
  end

  before do
    @provider1 = create(:provider)
    @provider2 = create(:provider)
    @provider_user_with_permissions = create(
      :provider_user,
      :with_view_safeguarding_information,
      :with_manage_organisations,
      :with_manage_users,
      :with_make_decisions,
      :with_view_diversity_information,
      providers: [@provider1],
      last_signed_in_at: 5.days.ago,
    )
    @provider_user2 = create(:provider_user, providers: [@provider2], last_signed_in_at: 5.days.ago)
    @provider_user3 = create(:provider_user, providers: [@provider1, @provider2], last_signed_in_at: 3.days.ago)
    create(:provider_user, providers: [@provider1])
  end

  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'returns provider_users and their permissions who have have signed in at least once' do
      expected_data = [
        {
          name: @provider_user_with_permissions.full_name,
          email_address: @provider_user_with_permissions.email_address,
          provider: @provider1.name,
          last_signed_in_at: @provider_user_with_permissions.last_signed_in_at,
          has_make_decisions: true,
          has_view_safeguarding: true,
          has_view_diversity: true,
          has_manage_users: true,
          has_manage_organisations: true,
          has_set_up_interviews: false,
        },
        {
          name: @provider_user2.full_name,
          email_address: @provider_user2.email_address,
          provider: @provider2.name,
          last_signed_in_at: @provider_user2.last_signed_in_at,
          has_make_decisions: false,
          has_view_safeguarding: false,
          has_view_diversity: false,
          has_manage_users: false,
          has_manage_organisations: false,
          has_set_up_interviews: false,
        },
        {
          name: @provider_user3.full_name,
          email_address: @provider_user3.email_address,
          provider: @provider1.name,
          last_signed_in_at: @provider_user3.last_signed_in_at,
          has_make_decisions: false,
          has_view_safeguarding: false,
          has_view_diversity: false,
          has_manage_users: false,
          has_manage_organisations: false,
          has_set_up_interviews: false,
        },
        {
          name: @provider_user3.full_name,
          email_address: @provider_user3.email_address,
          provider: @provider2.name,
          last_signed_in_at: @provider_user3.last_signed_in_at,
          has_make_decisions: false,
          has_view_safeguarding: false,
          has_view_diversity: false,
          has_manage_users: false,
          has_manage_organisations: false,
          has_set_up_interviews: false,
        },
      ]

      expect(described_class.new.data_for_export).to match_array(expected_data)
    end
  end
end
