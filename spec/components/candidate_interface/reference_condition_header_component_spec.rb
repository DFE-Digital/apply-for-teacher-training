require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceConditionHeaderComponent, type: :component do
  let(:result) do
    render_inline(described_class.new(reference_condition:, provider_name: 'Uni'))
  end

  context 'when no reference condition' do
    let(:reference_condition) { nil }

    it 'renders default message' do
      expect(result.text).to eq("Contact Uni if you need help getting references.\n")
    end
  end

  context 'when reference condition without description' do
    let(:reference_condition) { build(:reference_condition, description: nil) }

    it 'renders default message' do
      expect(result.text).to eq("Contact Uni if you need help getting references.\n")
    end
  end

  context 'when reference condition with description' do
    let(:reference_condition) { build(:reference_condition, description: 'Provider many references') }

    it 'renders condition description' do
      expect(result.text).to eq("  Uni said:\n  \n    \n      Provider many references\n    \nContact Uni if you need help getting references.\n")
    end
  end

  context 'when reference condition is met' do
    let(:reference_condition) { build(:reference_condition, status: :met) }

    it 'renders condition description' do
      expect(result.text).to be_empty
    end
  end
end
