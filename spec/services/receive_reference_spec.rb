require 'rails_helper'

RSpec.describe ReceiveReference do
  it 'updates the reference on an application form with the provided text' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    create(:reference, :unsubmitted, email_address: 'ab@c.com', application_form: application_form)
    create(:reference, :unsubmitted, email_address: 'xy@z.com', application_form: application_form)

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'xy@z.com',
      reference: "A reference",
    )

    expect(action).to be_valid
    action.save

    expect(application_form.references.find_by!(email_address: 'xy@z.com').reference).to eq('A reference')
    expect(application_form.references.find_by!(email_address: 'ab@c.com').reference).to be_nil
  end

  describe 'validation' do
    it 'validates the presence of referee email' do
      action = ReceiveReference.new(
        application_form: build_stubbed(:application_form),
        referee_email: nil,
        reference: "A reference",
      )

      expect(action).not_to be_valid
    end

    it 'validates that the referee email matches the references on the application form' do
      action = ReceiveReference.new(
        application_form: build_stubbed(:application_form),
        referee_email: 'madeupemail@example.com',
        reference: "A reference",
      )

      expect(action).not_to be_valid
    end
  end
end
