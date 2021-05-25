require 'rails_helper'

RSpec.describe SupportInterface::ApplicationNavigationComponent do
  let(:form) { build_stubbed(:application_form) }

  it 'renders a list of links' do
    candidate_id = form.candidate_id

    render_inline(described_class.new(form))

    expect(page).to have_link('Emails about this application', href: %r{email-log.+#{form.id}})
    expect(page).to have_link('Sentry errors for this candidate', href: %r{sentry.io.+#{candidate_id}})
    expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+#{candidate_id}})
  end

  describe 'logit link' do
    it 'is correct in the sandbox' do
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'production', SANDBOX: 'true') do
        render_inline(described_class.new(form))
        expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+apply-sandbox})
      end
    end

    it 'is correct in production' do
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'production') do
        render_inline(described_class.new(form))
        expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+apply-prod})
      end
    end

    it 'is correct in qa' do
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'qa') do
        render_inline(described_class.new(form))
        expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+apply-qa})
      end
    end

    it 'is correct in staging' do
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'staging') do
        render_inline(described_class.new(form))
        expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+apply-staging})
      end
    end

    it 'leaves empty quote marks in review' do
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'review') do
        render_inline(described_class.new(form))
        expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+application:%22%22})
      end
    end

    it 'leaves empty quote marks in development' do
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'development') do
        render_inline(described_class.new(form))
        expect(page).to have_link('Logit logs for this candidate', href: %r{logit.io.+application:%22%22})
      end
    end
  end
end
