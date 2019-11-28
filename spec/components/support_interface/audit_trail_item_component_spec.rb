require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailItemComponent do
  def candidate
    @candidate ||= build :candidate, email_address: 'bob@example.com'
  end

  def vendor_api_user
    @vendor_api_user ||= build :vendor_api_user, email_address: 'alice@example.com'
  end

  def provider_user
    @provider_user ||= ProviderUser.new(email_address: 'jim@example.com', dfe_sign_in_uid: 'abc')
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

  subject(:component) { described_class.new(audit: audit) }

  def render_result
    @render_result ||= render_inline(described_class, audit: audit)
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
end
