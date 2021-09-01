require 'rails_helper'

RSpec.describe PhaseBannerComponent do
  describe 'in production' do
    around do |ex|
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'production') { ex.run }
    end

    it 'renders a feedback link' do
      result = render_inline(described_class.new)

      expect(result.css('.govuk-link').attribute('href').value).to eq('mailto:becomingateacher@digital.education.gov.uk?subject=Feedback%20about%20Apply%20for%20teacher%20training')
    end

    specify 'the feedback link can be overridden' do
      result = render_inline(described_class.new(feedback_link: 'http://geocities.com'))

      expect(result.css('.govuk-link').attribute('href').value).to eq('http://geocities.com')
    end
  end

  describe 'in QA' do
    around do |ex|
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'qa') { ex.run }
    end

    it 'renders a feedback link' do
      result = render_inline(described_class.new)

      expect(result.css('.govuk-link').attribute('href').value).to eq('mailto:becomingateacher@digital.education.gov.uk?subject=Feedback%20about%20Apply%20for%20teacher%20training')
    end
  end
end
