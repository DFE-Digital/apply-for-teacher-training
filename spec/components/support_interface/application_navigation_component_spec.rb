require 'rails_helper'

RSpec.describe SupportInterface::ApplicationNavigationComponent do
  it 'renders a list of links' do
    form = build_stubbed(:application_form)
    candidate_id = form.candidate_id

    render_inline(described_class.new(form))

    expect(page).to have_link('Emails about this application', href: %r{email-log.+#{form.id}})
    expect(page).to have_link('Sentry errors for this candidate', href: %r{sentry.io.+#{candidate_id}})
    expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+#{candidate_id}.+hosting_environment:test})
  end
end
