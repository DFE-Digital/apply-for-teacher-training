require 'rails_helper'

RSpec.describe ProviderInterface::ConditionStatusTagComponent do
  let(:render) { render_inline(described_class.new(condition)) }

  context 'when the condition is pending' do
    let(:condition) { build(:offer_condition) }

    it 'renders a grey tag with the correct text' do
      expect(render.css('.govuk-tag--grey').text).to eq('Pending')
    end
  end

  context 'when the condition is met' do
    let(:condition) { build(:offer_condition, status: :met) }

    it 'renders a green tag with the correct text' do
      expect(render.css('.govuk-tag--green').text).to eq('Met')
    end
  end

  context 'when the condition is unmet' do
    let(:condition) { build(:offer_condition, status: :unmet) }

    it 'renders a red tag with the correct text' do
      expect(render.css('.govuk-tag--red').text).to eq('Not met')
    end
  end
end
