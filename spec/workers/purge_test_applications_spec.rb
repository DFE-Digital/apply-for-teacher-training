require 'rails_helper'

RSpec.describe PurgeTestApplications do
  it 'removes an application for bob@example.com' do
    create :application_form

    expect { described_class.new.perform }.to change { ApplicationForm.count }.by(-1)
  end

  it 'leaves an application for bob@example.org' do
    create :application_form, candidate: create(:candidate, email_address: 'bob@example.org')

    expect { described_class.new.perform }.not_to(change { ApplicationForm.count })
  end
end
