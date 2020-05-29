require 'rails_helper'

BROKEN_PREVIEWS = {
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
