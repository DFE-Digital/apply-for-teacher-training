require 'rails_helper'

RSpec.describe ReceiveReference do
  it 'updates the reference on an application form with the provided text' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references')
    create(:reference, :unsubmitted, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    ReceiveReference.new(
      reference: reference,
      feedback: 'A reference',
    ).save!

    expect(reference.feedback).to eq('A reference')
    expect(application_form.application_choices).to all(be_awaiting_references)
  end

  it 'progresses the application choices to the "application complete" status once all references have been received' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references', edit_by: 1.day.from_now)
    create(:reference, :complete, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    ReceiveReference.new(
      reference: reference,
      feedback: 'A reference',
    ).save!

    expect(application_form.application_choices).to all(be_application_complete)
  end

  it 'progresses the application choices to the "awaiting_provider_decision" status once all references have been received if edit_by has elapsed' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references', edit_by: 1.day.ago)
    create(:reference, :complete, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    ReceiveReference.new(
      reference: reference,
      feedback: 'A reference',
    ).save!

    expect(application_form.reload.application_choices).to all(be_awaiting_provider_decision)
  end

  it 'is okay with a 3rd reference being provided' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references', edit_by: 1.day.ago)
    create(:reference, :complete, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    ReceiveReference.new(
      reference: reference,
      feedback: 'A reference',
    ).save!

    another_reference = create(:reference, :unsubmitted, application_form: application_form)

    ReceiveReference.new(
      reference: another_reference,
      feedback: 'A 3rd reference',
    ).save!
  end
end
