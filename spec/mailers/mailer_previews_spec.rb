require 'rails_helper'

RSpec.describe 'Mailer previews' do
  ActionMailer::Preview.all.each do |preview|
    describe preview do
      preview.emails.each do |email|
        it email do
          expect { preview.call(email) }.not_to raise_error
        end
      end
    end
  end
end
