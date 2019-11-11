require 'rails_helper'

RSpec.describe SendApplicationsToProvider do
  it 'sends applications that were submitted 6 working days ago with 2 references' do
    application_form = create :application_form
    application_choice = create :application_choice, application_form: application_form, status: 'unsubmitted'
    Timecop.travel(10.days.ago) do
      SubmitApplication.new(application_form.reload).call
    end
    references = create_list :reference, 2, :unsubmitted, application_form: application_form
    references.each do |reference|
      ReceiveReference.new(
        application_form: application_form,
        referee_email: reference.email_address,
        feedback: 'seems ok',
      ).save
    end
    SendApplicationsToProvider.new.call
    expect(application_choice.reload.status).to eq 'awaiting_provider_decision'
  end

  it 'DOES NOT send applications that were submitted 6 working days ago with 1 reference' do
  end

  it 'DOES NOT send applications that were submitted 6 working days ago with no references' do
  end

  it 'DOES NOT send applications that were submitted 5 working days ago with 2 references' do
  end
end
