require 'rails_helper'

RSpec.describe Rails::MailersController do
  # These tests are designed to verify that DB changes from previews are rolled back
  #
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
    preview.emails.each do |email|
      it "/rails/mailers/#{preview.preview_name}/#{email} does not pollute the database" do
        expect { get(:preview, params: { path: "#{preview.preview_name}/#{email}" }) }.not_to(
          change { ApplicationForm.count },
        )
      end
    end
  end
end
