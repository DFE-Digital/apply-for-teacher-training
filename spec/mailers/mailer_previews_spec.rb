require 'rails_helper'

BROKEN_PREVIEWS = {
  'CandidateMailerPreview' => %w[new_referee_request chase_candidate_decision_with_one_offer new_offer_decisions_pending new_offer_single_offer chase_candidate_decision_with_multiple_offers new_offer_multiple_offers decline_last_application_choice new_referee_request_with_email_bounced chase_references_again withdraw_last_application_choice new_referee_request_with_refused],
  'RefereeMailerPreview' => %w[reference_request_email],
}.freeze

RSpec.describe 'Mailer previews' do
  ActionMailer::Preview.all.each do |preview|
    describe preview do
      preview.emails.each do |email|
        it email do
          pending 'currently broken' if BROKEN_PREVIEWS.fetch(preview.to_s, []).include?(email)
          expect { preview.call(email) }.not_to raise_error
        end
      end
    end
  end
end
