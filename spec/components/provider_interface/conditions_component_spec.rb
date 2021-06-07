require 'rails_helper'

RSpec.describe ProviderInterface::ConditionsComponent do
  describe 'rendered component' do
    it 'renders the conditions' do
      application_with_conditions_met = build_stubbed(:application_choice,
                                                      :with_offer,
                                                      :recruited)
      result = render_inline(described_class.new(application_choice: application_with_conditions_met))

      expect(result.to_html).to include(application_with_conditions_met.offer.conditions.first.text)
    end

    it 'indicates whether conditions are met' do
      offer = build(:offer, conditions: [build(:offer_condition, status: 'met')])
      application_with_conditions_met = build_stubbed(:application_choice,
                                                      :with_offer,
                                                      :recruited,
                                                      offer: offer)

      result = render_inline(described_class.new(application_choice: application_with_conditions_met))

      expect(result.css('.govuk-tag').text).to eq('Met')
    end

    it 'indicates whether conditions are pending' do
      application_with_pending_conditions = build_stubbed(:application_choice,
                                                          :with_offer,
                                                          :awaiting_provider_decision)
      result = render_inline(described_class.new(application_choice: application_with_pending_conditions))

      expect(result.css('.govuk-tag').text).to eq('Pending')
    end

    it 'indicates whether conditions are met for deferred offers' do
      offer = build(:offer, conditions: [build(:offer_condition, status: 'met')])
      application_with_conditions_met = build_stubbed(:application_choice,
                                                      :with_offer,
                                                      :offer_deferred,
                                                      status_before_deferral: 'recruited',
                                                      offer: offer)

      result = render_inline(described_class.new(application_choice: application_with_conditions_met))

      expect(result.css('.govuk-tag').text).to eq('Met')
    end

    it 'indicates whether conditions are pending for deferred offers' do
      application_with_pending_conditions = build_stubbed(:application_choice,
                                                          :with_offer,
                                                          :offer_deferred,
                                                          status_before_deferral: 'pending_conditions')

      result = render_inline(described_class.new(application_choice: application_with_pending_conditions))

      expect(result.css('.govuk-tag').text).to eq('Pending')
    end
  end
end
