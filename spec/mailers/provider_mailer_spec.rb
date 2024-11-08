require 'rails_helper'

RSpec.describe ProviderMailer do
  it_behaves_like 'mailer previews', ProviderMailerPreview
end
