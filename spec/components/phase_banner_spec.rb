require 'rails_helper'

RSpec.describe PhaseBanner do
  describe 'in production' do
    around do |ex|
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'production') { ex.run }
    end

    it 'renders a feedback link' do
      result = render_inline(PhaseBanner.new)

      expect(result.css('.govuk-link').attribute('href').value).to eq('mailto:becomingateacher@digital.education.gov.uk?subject=Apply+feedback')
    end

    specify 'the feedback link can be overridden' do
      result = render_inline(PhaseBanner.new(feedback_link: 'http://geocities.com'))

      expect(result.css('.govuk-link').attribute('href').value).to eq('http://geocities.com')
    end
  end
end
