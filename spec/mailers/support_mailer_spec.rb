require 'rails_helper'

RSpec.describe SupportMailer do
  include TestHelpers::MailerSetupHelper

  it_behaves_like 'mailer previews', Support::AuthenticationMailerPreview
end
