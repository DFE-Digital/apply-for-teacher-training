require 'rails_helper'

RSpec.describe ProviderInterface::SaveProviderUserService do
  def setup_wizard_double
    @providers = create_list(:provider, 3)
    instance_double(
      ProviderInterface::ProviderUserInvitationWizard,
      first_name: 'Ed',
      last_name: 'Yewcater',
      email_address: 'ed@example.com',
      provider_permissions: {
        @providers[0].id.to_s => { 'provider_id' => @providers[0].id.to_s, 'permissions' => %w[manage_users] },
        @providers[1].id.to_s => { 'provider_id' => @providers[1].id.to_s, 'permissions' => %w[make_decisions] },
      },
    )
  end

  it 'invokes a service to persist a new ProviderUser for a new user' do
    wizard = setup_wizard_double
    expect { described_class.new(wizard).call! }.to change { ProviderUser.count }.by(1)
    new_provider_user = ProviderUser.last
    expect(new_provider_user.provider_permissions.count).to eq 2

    first_permission = new_provider_user.provider_permissions.find { |permission| permission.provider_id == @providers[0].id }
    second_permission = new_provider_user.provider_permissions.find { |permission| permission.provider_id == @providers[1].id }
    expect(first_permission.manage_users).to be true
    expect(first_permission.make_decisions).to be false
    expect(second_permission.manage_users).to be false
    expect(second_permission.make_decisions).to be true
  end

  it 'invokes a service to persist the current state for an existing user' do
    wizard = setup_wizard_double
    existing_user = create(
      :provider_user,
      email_address: 'ed@example.com',
      first_name: 'Edward',
      last_name: 'Yewcater',
    )
    existing_user.provider_permissions.create!(
      provider: @providers[0],
      manage_users: false,
      make_decisions: true,
    )
    existing_user.provider_permissions.create!(
      provider: @providers[2],
      manage_users: true,
      make_decisions: true,
    )
    wizard = setup_wizard_double
    expect { described_class.new(wizard).call! }.not_to(change { ProviderUser.count })
    existing_user.reload
    expect(existing_user.provider_permissions.count).to eq 2

    first_permission = existing_user.provider_permissions.find { |permission| permission.provider_id == @providers[0].id }
    second_permission = existing_user.provider_permissions.find { |permission| permission.provider_id == @providers[1].id }
    expect(first_permission.manage_users).to be true
    expect(first_permission.make_decisions).to be false
    expect(second_permission.manage_users).to be false
    expect(second_permission.make_decisions).to be true
  end
end
