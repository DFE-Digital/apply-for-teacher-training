require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailComponent, with_audited: true do
  def candidate
    @candidate ||= create :candidate, email_address: 'bob@example.com'
  end

  def vendor_api_user
    @vendor_api_user ||= create :vendor_api_user, email_address: 'alice@example.com'
  end

  def application_form
    @application_form ||=
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        Audited.audit_class.as_user(candidate) do
          create(:application_form, candidate: candidate, first_name: 'Robert')
        end
      end
  end

  subject(:component) { described_class.new(audited_thing: application_form) }

  def render_result
    render_inline(described_class.new(audited_thing: application_form))
  end

  it 'renders a create application form audit record' do
    expect(render_result.text).to include('1 October 2019')
    expect(render_result.text).to include('12')
    expect(render_result.text).to include('Create Application Form')
    expect(render_result.text).to include('bob@example.com (Candidate)')
    expect(render_result.text).to match(/candidate_id\s*#{candidate.id}/m)
  end

  it 'renders an update application form audit record' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 10, 0)) do
      Audited.audit_class.as_user(candidate) do
        application_form.update(first_name: 'Bob')
      end
    end
    expect(render_result.text).to include('1 October 2019')
    expect(render_result.text).to include('12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('bob@example.com (Candidate)')
    expect(render_result.text).to match(/first_name\s*Robert → Bob/m)
  end

  it 'renders an update application form audit record with a Vendor API user' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 10, 0)) do
      Audited.audit_class.as_user(vendor_api_user) do
        application_form.update(last_name: 'Roberts')
      end
    end
    expect(render_result.text).to include('1 October 2019')
    expect(render_result.text).to include('12:10')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('alice@example.com (Vendor API)')
    expect(render_result.text).to match(/last_name\s*nil → Roberts/m)
  end

  it 'renders an update application form audit record without a user' do
    application_form.update(last_name: 'Roberts')
    expect(render_result.text).to include('Update Application Form')
    expect(render_result.text).to include('(Unknown User)')
  end

  it 'renders an update provider relationship permissions records for a ratifying provider' do
    ratifying_provider = create(:provider, name: 'B')
    provider_relationship_permissions =
      create(:provider_relationship_permissions,
             training_provider: create(:provider, name: 'A'),
             ratifying_provider: ratifying_provider)
    provider_relationship_permissions.update!(ratifying_provider_can_make_decisions: true)

    render_result = render_inline(described_class.new(audited_thing: ratifying_provider))

    expect(render_result.text).to include('Permission relationship between training provider A and ratifying provider B changed')
  end
end
