require 'rails_helper'

RSpec.describe DataMigrations::DeleteAllCourseAudits, with_audited: true do
  it 'deletes all course-related audits' do
    create_list(:course, 5)
    num = Audited::Audit.where(auditable_type: 'Course').count
    expect { described_class.new.change }.to change(Audited::Audit, :count).by(-1 * num)
    expect(Audited::Audit.count).not_to be_zero # providers, sites etc.
  end
end
