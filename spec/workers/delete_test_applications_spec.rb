require 'rails_helper'

RSpec.describe DeleteTestApplications do
  it 'removes an application for bob@example.com' do
    application_form = create(
      :completed_application_form,
      :with_degree,
      application_choices_count: 1,
      work_experiences_count: 1,
      volunteering_experiences_count: 1,
      references_count: 2,
      full_work_history: true,
    )
    create(
      :note,
      application_choice: application_form.application_choices.first,
    )

    expect { described_class.new.perform }.to change { ApplicationForm.count }.by(-1)
      .and change { ApplicationChoice.count }.by(-1)
      .and change { ApplicationWorkExperience.count }.by(-2)
      .and change { ApplicationVolunteeringExperience.count }.by(-1)
      .and change { ApplicationQualification.count }.by(-1)
      .and change { ApplicationWorkHistoryBreak.count }.by(-1)
      .and change { ApplicationReference.count }.by(-2)
      .and change { Note.count }.by(-1)
      .and change { Candidate.count }.by(-1)
  end

  it 'does nothing if the environment is not qa, dev or test other than raise an exception' do
    create :completed_application_form, application_choices_count: 1
    allow(HostingEnvironment).to receive(:environment_name).and_return('production')

    expect { described_class.new.perform }.to raise_error('You can only delete test applications in a test environment')
    expect(ApplicationForm.count).to be 1
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
