require 'rails_helper'

RSpec.describe ReceiveReference do
  it 'updates the reference on an application form with the provided text' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
    application_form.references << build(:reference, :unsubmitted, email_address: 'ab@c.com')
    application_form.references << build(:reference, :unsubmitted, email_address: 'xy@z.com')

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'xy@z.com',
      feedback: 'A reference',
    )

    expect(action).to be_valid
    expect(action.save).to be true

    expect(application_form.references.find_by!(email_address: 'xy@z.com').feedback).to eq('A reference')
    expect(application_form.references.find_by!(email_address: 'ab@c.com').feedback).to be_nil
  end

  it 'progresses the application choices to the "application complete" status once all references have been received' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references', edit_by: 1.day.from_now) }
    application_form.references << build(:reference, :unsubmitted, email_address: 'ab@c.com')
    application_form.references << build(:reference, :complete)

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'ab@c.com',
      feedback: 'A reference',
    )
    action.save

    expect(application_form).to be_references_complete
    expect(application_form.application_choices).to all(be_application_complete)
  end

  it 'does not progress the application choices to the "application complete" status without minimum number of references' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
    application_form.references << build(:reference, :unsubmitted, email_address: 'ab@c.com')

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'ab@c.com',
      feedback: 'A reference',
    )
    action.save

    expect(application_form).not_to be_references_complete
    expect(application_form.application_choices).to all(be_awaiting_references)
  end

  describe 'validation' do
    it 'validates the presence of referee email' do
      action = ReceiveReference.new(
        application_form: build_stubbed(:application_form),
        referee_email: nil,
        feedback: 'A reference',
      )

      expect(action).not_to be_valid
    end

    it 'validates that the referee email matches the references on the application form' do
      action = ReceiveReference.new(
        application_form: build_stubbed(:application_form),
        referee_email: 'madeupemail@example.com',
        feedback: 'A reference',
      )

      expect(action).not_to be_valid
    end
  end
end
