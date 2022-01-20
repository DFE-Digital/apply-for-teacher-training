require 'rails_helper'

RSpec.describe ProviderInterface::ConditionsListComponent do
  let(:render) { render_inline(described_class.new(conditions)) }

  context 'when there are no conditions' do
    let(:conditions) { [] }

    it 'renders text' do
      expect(render.css('p').text).to eq('No conditions have been set for this offer.')
    end
  end

  context 'when there are conditions' do
    let(:conditions) do
      [
        build_stubbed(:offer_condition),
        build_stubbed(:offer_condition, status: 'met'),
      ]
    end

    it 'renders a list of conditions with their statuses' do
      expect(render.css('.govuk-summary-list__key').first.text.squish).to eq(conditions.first.text)
      expect(render.css('.govuk-summary-list__value').first.text.squish).to eq('Pending')

      expect(render.css('.govuk-summary-list__key').last.text.squish).to eq(conditions.last.text)
      expect(render.css('.govuk-summary-list__value').last.text.squish).to eq('Met')
    end
  end

  context 'when there are standard conditions' do
    let(:standard_condition_1) { build_stubbed(:offer_condition, text: 'Fitness to train to teach check') }
    let(:standard_condition_2) { build_stubbed(:offer_condition, text: 'Disclosure and Barring Service (DBS) check') }
    let(:further_condition) { build_stubbed(:offer_condition) }

    let(:conditions) do
      [
        further_condition,
        standard_condition_2,
        standard_condition_1,
      ]
    end

    it 'renders a list of conditions with their statuses' do
      expect(render.css('.govuk-summary-list__key').first.text.squish).to eq(standard_condition_1.text)
      expect(render.css('.govuk-summary-list__key')[1].text.squish).to eq(standard_condition_2.text)
      expect(render.css('.govuk-summary-list__key').last.text.squish).to eq(further_condition.text)
    end
  end
end
