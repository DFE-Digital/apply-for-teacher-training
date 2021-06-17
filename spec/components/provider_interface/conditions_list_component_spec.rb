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
end
