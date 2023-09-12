require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailItemComponent do
  def candidate
    @candidate ||= build(:candidate, email_address: 'bob@example.com')
  end

  def vendor_api_user
    @vendor_api_user ||= build(:vendor_api_user, email_address: 'alice@example.com')
  end

  def provider_user
    @provider_user ||= ProviderUser.new(email_address: 'jim@example.com', dfe_sign_in_uid: 'abc')
  end

  def support_user
    @support_user ||= SupportUser.new(email_address: 'alice@support.com', dfe_sign_in_uid: 'alice')
  end

  def discarded_support_user
    @discarded_support_user ||= SupportUser.new(email_address: 'discarded@support.com', dfe_sign_in_uid: 'alice', discarded_at: Time.zone.now)
  end

  def audit
    @audit ||= Audited::Audit.new(
      user: candidate,
      action: 'update',
      auditable_type: 'ApplicationForm',
      created_at: Time.zone.local(2019, 10, 1, 12, 10, 0),
      audited_changes: {},
    )
  end

  subject(:component) { described_class.new(audit:) }

  def render_result
    @render_result ||= render_inline(described_class.new(audit:))
  end

  it 'renders an update application form audit record' do
    expect(render_result.text).to include('1 October 2019 12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('bob@example.com (Candidate)')
  end

  it 'renders an update application form audit record with a Vendor API user' do
    audit.user = vendor_api_user
    audit.action = 'update'
    expect(render_result.text).to include('1 October 2019 12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('alice@example.com (Vendor API)')
  end

  it 'renders comment-only update on application form audit record with a Vendor API user' do
    audit.user = vendor_api_user
    audit.action = 'update'
    audit.comment = 'some comment'
    expect(render_result.text).to include('1 October 2019 12:10')
    expect(render_result.text).to include('Comment on Application Form')
    expect(render_result.text).to include('some comment')
    expect(render_result.text).to include('alice@example.com (Vendor API)')
  end

  it 'renders an update on application form audit record with a Support User' do
    audit.user = support_user
    audit.action = 'update'
    expect(render_result.text).to include('1 October 2019 12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('alice@support.com (Support user)')
  end

  it 'renders an update on application form audit record with a discarded Support User' do
    audit.user = discarded_support_user
    audit.action = 'update'
    expect(render_result.text).to include('1 October 2019 12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('discarded@support.com (Support user)')
  end

  it 'renders an update on application form audit record with a Provider User' do
    audit.user = provider_user
    audit.action = 'update'
    expect(render_result.text).to include('1 October 2019 12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('jim@example.com (Provider user)')
  end

  it 'renders an update on application form audit record with a referee' do
    audit.user = build(:reference, name: 'Harry', email_address: 'harry@hogwarts.edu')
    audit.action = 'update'
    expect(render_result.text).to include('Harry - harry@hogwarts.edu (Referee)')
  end

  it 'renders an update on application form audit record with a deleted referee' do
    audit.user_type = 'ApplicationReference'
    audit.user_id = 412563789101
    audit.action = 'update'

    expect(render_result.text).to include('Deleted referee')
  end

  it 'renders an update application form audit record with the username (rather than a persistent model)' do
    audit.user = nil
    audit.username = 'SYSTEM'
    audit.action = 'update'
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('SYSTEM')
  end

  it 'renders an update application form audit record without a user' do
    audit.user = nil
    audit.action = 'update'
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('(Unknown User)')
  end

  context 'the audited item is a ProviderPermissions record' do
    # let! these so we do not wastefully create audits we do not care about
    # in the body of the spec
    let!(:provider) { create(:provider, name: 'The School of Roke') }
    let!(:user) { create(:provider_user) }

    it 'provides a meaningful label for "create"', :with_audited do
      permissions = ProviderPermissions.create(
        provider:,
        provider_user: user,
      )

      render_inline(described_class.new(audit: permissions.audits.last)) do |rendered_component|
        assert_includes rendered_component, 'Access granted for The School of Roke'
      end
    end

    it 'provides a meaningful label for "update"', :with_audited do
      permissions = ProviderPermissions.create(
        provider:,
        provider_user: user,
      )

      permissions.manage_users = !permissions.manage_users
      permissions.save

      render_inline(described_class.new(audit: permissions.audits.last)) do
        assert_includes rendered_component, 'Permissions changed for The School of Roke'
      end
    end

    it 'provides a meaningful label for "update", even when the original record was destroyed', :with_audited do
      permissions = ProviderPermissions.create(
        provider:,
        provider_user: user,
      )

      permissions.manage_users = !permissions.manage_users
      permissions.save

      permissions.destroy

      render_inline(
        described_class.new(audit: permissions.audits.find_by(action: 'update')),
      ) do |rendered_component|
        assert_includes rendered_component, 'Permissions changed for The School of Roke'
      end
    end

    it 'renders a label for "update" even when the provider cannot be found', :with_audited do
      permissions = ProviderPermissions.create(
        provider:,
        provider_user: user,
      )

      permissions.manage_users = !permissions.manage_users
      permissions.save

      permissions.destroy # no provider available from permissions record
      permissions.audits.find_by(action: 'create').destroy # no creation record to fall back to

      render_inline(
        described_class.new(audit: permissions.audits.find_by(action: 'update')),
      ) do |rendered_component|
        assert_includes rendered_component, 'Permissions changed for a provider'
      end
    end

    it 'provides a meaningful label for "destroy"', :with_audited do
      permissions = ProviderPermissions.create(
        provider:,
        provider_user: user,
      )

      permissions.destroy

      render_inline(described_class.new(audit: permissions.audits.last)) do |rendered_component|
        assert_includes rendered_component, 'Access revoked for The School of Roke'
      end
    end
  end

  context 'the audited item is a ProviderRelationshipPermissions record' do
    let!(:training_provider) { create(:provider, name: 'A') }
    let!(:ratifying_provider) { create(:provider, name: 'B') }

    it 'provides a meaningful label for "create"', :with_audited do
      permissions = ProviderRelationshipPermissions.create(
        training_provider_id: training_provider.id,
        ratifying_provider_id: ratifying_provider.id,
        training_provider_can_make_decisions: true,
        ratifying_provider_can_view_safeguarding_information: true,
      )
      render_inline(described_class.new(audit: permissions.audits.last)) do |rendered_component|
        assert_includes rendered_component, 'Permission relationship between training provider A and ratifying provider B created'
      end
    end

    it 'provides a meaningful label for "update"', :with_audited do
      permissions = ProviderRelationshipPermissions.create(
        training_provider_id: training_provider.id,
        ratifying_provider_id: ratifying_provider.id,
        training_provider_can_make_decisions: true,
        ratifying_provider_can_view_safeguarding_information: true,
      )

      permissions.update!(
        training_provider_can_make_decisions: false,
        ratifying_provider_can_make_decisions: true,
      )
      render_inline(described_class.new(audit: permissions.audits.last)) do |rendered_component|
        assert_includes rendered_component, 'Permission relationship between training provider A and ratifying provider B changed'
      end
    end
  end
end
