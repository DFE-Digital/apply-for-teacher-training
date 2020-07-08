require 'rails_helper'

# These tests are designed to verify that `ApplyMailersController` is rolling back DB changes
RSpec.describe Rails::MailersController, type: :controller do
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
