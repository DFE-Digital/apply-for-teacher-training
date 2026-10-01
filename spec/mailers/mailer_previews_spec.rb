require 'rails_helper'

RSpec.describe 'Mailer previews' do
  # mail-notify 2.x registers MailNotifyPreviewInterceptor, which renders each preview by
  # calling the Notify API
  # Restoring the default interceptor list keeps them offline: previews render from the
  around do |example|
    original_interceptors = ActionMailer::Base.preview_interceptors
    ActionMailer::Base.preview_interceptors = [ActionMailer::InlinePreviewInterceptor]
    example.run
  ensure
    ActionMailer::Base.preview_interceptors = original_interceptors
  end

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
