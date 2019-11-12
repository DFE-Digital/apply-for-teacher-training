require 'rails_helper'

RSpec.describe SendApplicationsToProvider do
  def create_application_with_references
    application_form = create :application_form
    create :application_choice, application_form: application_form, status: 'unsubmitted'
    SubmitApplication.new(application_form.reload).call
    create_list :reference, 2, :unsubmitted, application_form: application_form
    application_form
  end

  def complete_reference(reference)
    ReceiveReference.new(
      application_form: reference.application_form,
      referee_email: reference.email_address,
      feedback: 'seems ok',
    ).save
  end

  it 'sends an application submitted 6 working days ago with 2 references' do
    application_form = create_application_with_references
    application_form.references.each do |reference|
      complete_reference(reference)
    end
    Timecop.travel(6.business_days.from_now) do
      SendApplicationsToProvider.new.perform
    end
    expect(application_form.application_choices.first.reload.status).to eq 'awaiting_provider_decision'
  end

  it 'DOES NOT send an application submitted 6 working days ago with no references' do
    application_form = create_application_with_references
    Timecop.travel(6.business_days.from_now) do
      SendApplicationsToProvider.new.perform
    end
    expect(application_form.application_choices.first.reload.status).to eq 'awaiting_references'
  end
end
