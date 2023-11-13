require 'rails_helper'

RSpec.describe SupportInterface::ApplicationNavigationComponent do
  let(:form) { build_stubbed(:application_form) }

  it 'renders a list of links' do
    candidate_id = form.candidate_id

    render_inline(described_class.new(form))

    expect(page).to have_link('Emails about this application', href: /email-log.+#{form.id}/)
    expect(page).to have_link('Sentry errors for this candidate', href: /sentry.io.+#{candidate_id}/)
  end
end
