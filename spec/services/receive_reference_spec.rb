require 'rails_helper'

RSpec.describe ReceiveReference do
  it 'updates the reference on an application form with the provided text' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
    application_form.application_references << build(:reference, :unsubmitted, email_address: 'ab@c.com')
    application_form.application_references << build(:reference, :unsubmitted, email_address: 'xy@z.com')

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'xy@z.com',
      feedback: 'A reference',
    )

    expect(action).to be_valid
    expect(action.save).to be true

    expect(application_form.application_references.find_by!(email_address: 'xy@z.com').feedback).to eq('A reference')
    expect(application_form.application_references.find_by!(email_address: 'ab@c.com').feedback).to be_nil
  end

  it 'progresses the application choices to the "application complete" status once all references have been received' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references', edit_by: 1.day.from_now) }
    application_form.application_references << build(:reference, :unsubmitted, email_address: 'ab@c.com')
    application_form.application_references << build(:reference, :complete)

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'ab@c.com',
      feedback: 'A reference',
    )
    action.save

    expect(application_form.reload).to be_application_references_complete
    expect(application_form.application_choices).to all(be_application_complete)
  end

  it 'does not progress the application choices to the "application complete" status without minimum number of references' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
    application_form.application_references << build(:reference, :unsubmitted, email_address: 'ab@c.com')

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'ab@c.com',
      feedback: 'A reference',
    )
    action.save

    expect(application_form).not_to be_application_references_complete
    expect(application_form.application_choices).to all(be_awaiting_references)
  end

  it 'progresses the application choices to the "awaiting_provider_decision" status once all references have been received if edit_by has elapsed' do
    application_form = FactoryBot.create(:completed_application_form, references_count: 0)
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references', edit_by: 1.day.ago) }
    application_form.application_references << build(:reference, :unsubmitted, email_address: 'ab@c.com')
    application_form.application_references << build(:reference, :complete)

    action = ReceiveReference.new(
      application_form: application_form,
      referee_email: 'ab@c.com',
      feedback: 'A reference',
    )
    action.save

    expect(application_form.reload).to be_application_references_complete
    expect(application_form.application_choices).to all(be_awaiting_provider_decision)
  end

  describe 'validation' do
    it 'validates the presence of referee email and feedback' do
      action = ReceiveReference.new(
        application_form: build_stubbed(:application_form),
        referee_email: nil,
        feedback: '',
      )

      expect(action).not_to be_valid

      expect(action.errors[:feedback]).to eq(['Enter your reference'])
      expect(action.errors[:referee_email]).not_to be_empty
    end

    it 'validates the feedback is max 300 words' do
      action = ReceiveReference.new(
        application_form: build_stubbed(:application_form),
        referee_email: nil,
        feedback: Faker::Lorem.sentence(word_count: 301),
        )

      expect(action).not_to be_valid

      expect(action.errors[:feedback]).to eq(['Your reference must be 300 words or fewer'])
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
