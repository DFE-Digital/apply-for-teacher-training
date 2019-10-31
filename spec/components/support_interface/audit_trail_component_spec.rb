require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailComponent do
  def candidate
    @candidate ||= create :candidate, email_address: 'bob@example.com'
  end

  def vendor_api_user
    @vendor_api_user ||= create :vendor_api_user, email_address: 'alice@example.com'
  end

  def application_form
    @application_form ||= begin
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        Audited.audit_class.as_user(candidate) do
          create(:application_form, candidate: candidate, first_name: 'Robert')
        end
      end
    end
  end

  subject(:component) { described_class.new(application_form: application_form) }

  def render_result
    render_inline(described_class, application_form: application_form)
  end

  it 'renders a create application form audit record' do
    expect(render_result.text).to include('October 01, 2019 12:00:00')
    expect(render_result.text).to include('Create Application Form - bob@example.com (Candidate)')
    expect(render_result.text).to match(/candidate_id\s*#{candidate.id}/m)
  end

  it 'renders an update application form audit record' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 10, 0)) do
      Audited.audit_class.as_user(candidate) do
        application_form.update(first_name: 'Bob')
      end
    end
    expect(render_result.text).to include('October 01, 2019 12:10:00')
    expect(render_result.text).to include('Update Application Form - bob@example.com (Candidate)')
    expect(render_result.text).to match(/first_name\s*Robert → Bob/m)
  end

  it 'renders an update application form audit record with a Vendor API user' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 10, 0)) do
      Audited.audit_class.as_user(vendor_api_user) do
        application_form.update(last_name: 'Roberts')
      end
    end
    expect(render_result.text).to include('October 01, 2019 12:10:00')
    expect(render_result.text).to include('Update Application Form - alice@example.com (Vendor API)')
    expect(render_result.text).to match(/last_name\s*nil → Roberts/m)
  end

  it 'renders an update application form audit record without a user' do
    application_form.update(last_name: 'Roberts')
    expect(render_result.text).to include('Update Application Form - (Unknown User)')
  end
end
