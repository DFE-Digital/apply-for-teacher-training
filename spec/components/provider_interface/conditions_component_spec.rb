require 'rails_helper'

RSpec.describe ProviderInterface::ConditionsComponent do
  describe 'rendered component' do
    let(:conditions) { ['Fitness to teach check'] }

    it 'renders the conditions' do
      application_with_conditions_met = build(:application_choice, status: 'recruited', offer: { 'conditions' => conditions })
      result = render_inline(described_class.new(application_choice: application_with_conditions_met))

      expect(result.to_html).to include('Fitness to teach check')
    end

    it 'indicates whether conditions are met' do
      application_with_conditions_met = build(:application_choice, status: 'recruited', offer: { 'conditions' => conditions })
      result = render_inline(described_class.new(application_choice: application_with_conditions_met))

      expect(result.css('.govuk-tag').text).to eq('Met')
    end

    it 'indicates whether conditions are pending' do
      application_with_pending_conditions = build(:application_choice, status: 'awaiting_provider_decision', offer: { 'conditions' => conditions })
      result = render_inline(described_class.new(application_choice: application_with_pending_conditions))

      expect(result.css('.govuk-tag').text).to eq('Pending')
    end

    it 'indicates whether conditions are met for deferred offers' do
      application_with_conditions_met = build(:application_choice,
                                              status: 'offer_deferred',
                                              status_before_deferral: 'recruited',
                                              offer: { 'conditions' => conditions })

      result = render_inline(described_class.new(application_choice: application_with_conditions_met))

      expect(result.css('.govuk-tag').text).to eq('Met')
    end

    it 'indicates whether conditions are pending for deferred offers' do
      application_with_pending_conditions = build(:application_choice,
                                                  status: 'offer_deferred',
                                                  status_before_deferral: 'pending_conditions',
                                                  offer: { 'conditions' => conditions })

      result = render_inline(described_class.new(application_choice: application_with_pending_conditions))

      expect(result.css('.govuk-tag').text).to eq('Pending')
    end
  end
end
