require 'rails_helper'

RSpec.describe GetApplicationChoicesReadyToSendToProvider do
  def create_application_with_references
    application_form = create :application_form
    create :application_choice, application_form: application_form, status: 'unsubmitted'
    create_list :reference, 2, :unsubmitted, application_form: application_form
    SubmitApplication.new(application_form.reload).call
    application_form.reload
  end

  def complete_reference(application_form, email_address)
    ReceiveReference.new(
      application_form: application_form,
      referee_email: email_address,
      feedback: 'seems ok',
    ).save
  end

  it 'returns an application submitted 6 working days ago with 2 references' do
    application_form = create_application_with_references
    application_form.references.each do |reference|
      complete_reference(application_form, reference.email_address)
    end
    Timecop.travel(6.business_days.from_now) do
      expect(described_class.call).to include application_form.application_choices.first
    end
  end

  it 'does NOT return an application submitted 6 working days ago with only 1 reference' do
    application_form = create_application_with_references
    complete_reference(application_form, application_form.references.first.email_address)
    Timecop.travel(6.business_days.from_now) do
      expect(described_class.call).not_to include application_form.application_choices.first
    end
  end

  it 'does NOT return an application submitted 6 working days ago with no references' do
    application_form = create_application_with_references
    Timecop.travel(6.business_days.from_now) do
      expect(described_class.call).not_to include application_form.application_choices.first
    end
  end

  it 'does NOT return an application submitted 5 working days ago with 2 references' do
    application_form = create_application_with_references
    application_form.references.each do |reference|
      complete_reference(application_form, reference.email_address)
    end
    Timecop.travel(5.business_days.from_now) do
      expect(described_class.call).not_to include application_form.application_choices.first
    end
  end
end
