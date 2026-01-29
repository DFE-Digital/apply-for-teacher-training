require 'rails_helper'

RSpec.describe ProviderMailer do
  it_behaves_like 'mailer previews', Provider::AuthenticationMailerPreview
  it_behaves_like 'mailer previews', Provider::OrganisationPermissionsMailerPreview
  it_behaves_like 'mailer previews', Provider::ApplicationsMailerPreview
  it_behaves_like 'mailer previews', Provider::DeadlinesMailerPreview
  it_behaves_like 'mailer previews', Provider::ReferencesMailerPreview
  it_behaves_like 'mailer previews', Provider::ReportMailerPreview
end
