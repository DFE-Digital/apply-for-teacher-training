require 'rails_helper'

RSpec.describe ProviderInterface::SkeConditionsComponent do
  let(:application_choice) { create(:application_choice) }
  let(:course) { create(:course) }
  let(:editable) { true }
  let(:result) do
    render_inline(
      described_class.new(
        application_choice:,
        course:,
        ske_condition:,
        editable:,
      ),
    )
  end

  context 'when a language ske condition' do
    let(:ske_condition) { build(:ske_condition, :language, length: '8', subject: 'French', reason: 'different_degree') }

    it 'renders the selected SKE values' do
      expect(result.text).to include('SubjectFrench')
      expect(result.text).to include('Length8 weeks')
      expect(result.text).to include('ReasonTheir degree subject was not French')
    end
  end

  context 'when a standard ske condition' do
    let(:ske_condition) { build(:ske_condition, length: '8', subject: 'Mathematics', reason: 'different_degree') }

    it 'renders the subject from the course' do
      expect(result.text).to include('SubjectMathematics')
      expect(result.text).to include('Length8 weeks')
      expect(result.text).to include('ReasonTheir degree subject was not Mathematics')
    end
  end
end
