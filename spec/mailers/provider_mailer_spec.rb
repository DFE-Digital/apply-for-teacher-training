require 'rails_helper'

RSpec.describe ProviderMailer do
  it_behaves_like 'mailer previews', ProviderMailerPreview
  it_behaves_like 'mailer previews', Provider::AuthenticationMailerPreview
  it_behaves_like 'mailer previews', Provider::OrganisationPermissionsMailerPreview
  it_behaves_like 'mailer previews', Provider::ApplicationsMailerPreview
end
