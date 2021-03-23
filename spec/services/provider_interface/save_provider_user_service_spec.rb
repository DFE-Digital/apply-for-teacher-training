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

  def setup_actor
    actor = create :provider_user, create_notification_preference: false
    @providers.each do |provider|
      actor.provider_permissions.create(provider: provider, manage_users: true)
    end
    actor
  end

  it 'invokes a service to persist a new ProviderUser for a new user' do
    wizard = setup_wizard_double
    actor = setup_actor
    expect { described_class.new(actor: actor, wizard: wizard).call! }.to change { ProviderUser.count }.by(1)
    new_provider_user = ProviderUser.last
    expect(new_provider_user.provider_permissions.count).to eq 2

    first_permission = new_provider_user.provider_permissions.find { |permission| permission.provider_id == @providers[0].id }
    second_permission = new_provider_user.provider_permissions.find { |permission| permission.provider_id == @providers[1].id }
    expect(first_permission.manage_users).to be true
    expect(first_permission.make_decisions).to be false
    expect(second_permission.manage_users).to be false
    expect(second_permission.make_decisions).to be true
  end

  it 'adds the notification preferences record to a ProviderUser' do
    wizard = setup_wizard_double
    actor = setup_actor

    expect { described_class.new(actor: actor, wizard: wizard).call! }.to change(ProviderUserNotificationPreferences, :count).by(1)
  end

  it 'invokes a service to persist the current state for an existing user' do
    wizard = setup_wizard_double
    actor = setup_actor
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
    expect { described_class.new(actor: actor, wizard: wizard).call! }.not_to(change { ProviderUser.count })
    existing_user.reload
    expect(existing_user.provider_permissions.count).to eq 3

    first_permission = existing_user.provider_permissions.find { |permission| permission.provider_id == @providers[0].id }
    second_permission = existing_user.provider_permissions.find { |permission| permission.provider_id == @providers[1].id }
    third_permission = existing_user.provider_permissions.find { |permission| permission.provider_id == @providers[2].id }
    expect(first_permission.manage_users).to be true
    expect(first_permission.make_decisions).to be false
    expect(second_permission.manage_users).to be false
    expect(second_permission.make_decisions).to be true
    expect(third_permission.make_decisions).to be true
    expect(third_permission.manage_users).to be true
  end

  it 'raises an exception if the actor does not have manage_user permission on all providers' do
    wizard = setup_wizard_double
    actor = setup_actor
    actor.provider_permissions.find_by(provider: @providers[1]).update(manage_users: false)
    expect { described_class.new(actor: actor, wizard: wizard).call! }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
  end

  context 'when no permissions are granted' do
    it 'invokes a service to persist a new ProviderUser for a new user' do
      @providers = create_list(:provider, 3)
      wizard = instance_double(
        ProviderInterface::ProviderUserInvitationWizard,
        first_name: 'Ed',
        last_name: 'Yewcater',
        email_address: 'ed@example.com',
        provider_permissions: {
          @providers[0].id.to_s => { 'provider_id' => @providers[0].id.to_s },
          @providers[1].id.to_s => { 'provider_id' => @providers[1].id.to_s },
        },
      )
      actor = setup_actor
      expect { described_class.new(actor: actor, wizard: wizard).call! }.to change { ProviderUser.count }.by(1)
      new_provider_user = ProviderUser.last
      expect(new_provider_user.provider_permissions.count).to eq 2

      first_permission = new_provider_user.provider_permissions.find { |permission| permission.provider_id == @providers[0].id }
      second_permission = new_provider_user.provider_permissions.find { |permission| permission.provider_id == @providers[1].id }
      expect(first_permission.manage_users).to be false
      expect(first_permission.make_decisions).to be false
      expect(second_permission.manage_users).to be false
      expect(second_permission.make_decisions).to be false
    end
  end
end
