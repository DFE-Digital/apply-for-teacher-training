require 'rails_helper'

RSpec.describe Covid19::CandidateEmailDelivery, sidekiq: true do
  describe '#send_delay_emails' do
    it 'sends the delay email to all relevant candidates' do
      recipient_candidate_one = create(:candidate) do |candidate|
        candidate.application_forms = [
          create(:application_form, candidate: candidate) do |af|
            create(:application_choice, application_form: af, status: :offer)
            create(:application_choice, application_form: af, status: :pending_conditions)
            create(:application_choice, application_form: af, status: :awaiting_provider_decision)
          end,
        ]
      end

      recipient_candidate_two = create(:candidate) do |candidate|
        candidate.application_forms = [
          create(:application_form, candidate: candidate) do |af|
            create(:application_choice, application_form: af, status: :rejected)
            create(:application_choice, application_form: af, status: :offer)
            create(:application_choice, application_form: af, status: :offer)
          end,
        ]
      end

      # ignored candidate 1
      create(:candidate) do |candidate|
        candidate.application_forms = [
          create(:application_form, candidate: candidate) do |af|
            create(:application_choice, application_form: af, status: :withdrawn)
            create(:application_choice, application_form: af, status: :rejected)
            create(:application_choice, application_form: af, status: :declined)
          end,
        ]
      end

      # ignored candidate 2
      create(:candidate) do |candidate|
        candidate.application_forms = [
          create(:application_form, candidate: candidate) do |af|
            create(:application_choice, application_form: af, status: :conditions_not_met)
            create(:application_choice, application_form: af, status: :recruited)
            create(:application_choice, application_form: af, status: :enrolled)
          end,
        ]
      end

      Covid19::CandidateEmailDelivery.new.send_delay_emails

      emails = CandidateMailer.deliveries
      expect(emails.count).to eq 2
      expect(emails.map(&:to).flatten).to match_array [
        recipient_candidate_one.email_address,
        recipient_candidate_two.email_address,
      ]
    end
  end
end
