require 'rails_helper'

RSpec.describe PurgeTestApplications do
  it 'removes an application for bob@example.com' do
    create :completed_application_form, application_choices_count: 1

    expect { described_class.new.perform }.to change { ApplicationForm.count }.by(-1)
      .and change { ApplicationChoice.count }.by(-1)
      .and change { Candidate.count }.by(-1)
  end

  it 'leaves an application for bob@example.org' do
    create(
      :completed_application_form,
      application_choices_count: 1,
      candidate: create(:candidate, email_address: 'bob@example.org'),
    )

    expect { described_class.new.perform }.not_to(change { ApplicationForm.count })
  end
end
