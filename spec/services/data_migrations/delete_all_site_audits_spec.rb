require 'rails_helper'

RSpec.describe DataMigrations::DeleteAllSiteAudits, with_audited: true do
  it 'deletes all site-related audits' do
    create_list(:site, 5)
    num = Audited::Audit.where(auditable_type: 'Site').count
    expect { described_class.new.change }.to change(Audited::Audit, :count).by(-1 * num)
    expect(Audited::Audit.count).not_to be_zero # providers etc.
  end
end
