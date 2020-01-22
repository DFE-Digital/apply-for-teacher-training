require 'rails_helper'

RSpec.describe RequestReference do
  context 'outside the Sandbox environment', sandbox: false do
    it 'saves the reference without feedback' do
      application_form = FactoryBot.create :application_form

      action = RequestReference.new(
        application_form: application_form,
        referee_params: {
          email_address: 'bob@example.com',
          name: 'Bob',
          relationship: 'Teacher',
        },
      )

      expect(action.call).to be true
      expect(action.referee.persisted?).to be true
      expect(action.referee.name).to eq 'Bob'
      expect(action.referee.feedback).to be_nil
    end
  end

  context 'in the Sandbox environment', sandbox: true do
    it 'saves the reference without feedback if the email_address does not match the auto-referees' do
      application_form = FactoryBot.create :application_form

      action = RequestReference.new(
        application_form: application_form,
        referee_params: {
          email_address: 'bob@example.com',
          name: 'Bob',
          relationship: 'Teacher',
        },
      )

      expect(action.call).to be true
      expect(action.referee.persisted?).to be true
      expect(action.referee.name).to eq 'Bob'
      expect(action.referee.feedback).to be_nil
    end

    it 'saves the reference with automatic feedback if the email_address does match one of the auto-referees' do
      application_form = FactoryBot.create :application_form

      action = RequestReference.new(
        application_form: application_form,
        referee_params: {
          email_address: 'refbot1@example.com',
          name: 'Bob',
          relationship: 'Teacher',
        },
      )

      expect(action.call).to be true
      expect(action.referee.persisted?).to be true
      expect(action.referee.name).to eq 'Bob'
      expect(action.referee.feedback).not_to be_nil
    end
  end
end
