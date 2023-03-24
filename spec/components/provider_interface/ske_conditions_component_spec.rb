require 'rails_helper'

RSpec.describe ProviderInterface::SkeConditionsComponent do
  let(:application_choice) { create(:application_choice) }
  let(:course) { create(:course) }
  let(:editable) { false }
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
    let(:ske_condition) { build(:ske_condition, :language, length: '8', subject: 'French', reason: SkeCondition::DIFFERENT_DEGREE_REASON, status: :met) }

    it 'renders the selected SKE values' do
      expect(result.text).to include('SubjectFrench')
      expect(result.text).to include('Length8 weeks')
      expect(result.text).to include('ReasonTheir degree subject was not French')
    end

    it 'renders the condition status' do
      expect(result.text).to include('Met')
    end

    context 'when the SKE condition is editable' do
      let(:editable) { true }

      it 'renders a Change link' do
        expect(result.css('header.app-summary-card__header a').text).to eq('Remove condition')
      end
    end
  end

  context 'when a standard ske condition' do
    let(:ske_condition) { build(:ske_condition, length: '8', subject: 'Mathematics', reason: SkeCondition::DIFFERENT_DEGREE_REASON, status: :pending) }

    it 'renders the subject from the course' do
      expect(result.text).to include('SubjectMathematics')
      expect(result.text).to include('Length8 weeks')
      expect(result.text).to include('ReasonTheir degree subject was not Mathematics')
    end

    it 'renders the condition status' do
      expect(result.text).to include('Pending')
    end

    context 'when the SKE condition is editable' do
      let(:editable) { true }

      it 'renders a Change link' do
        expect(result.css('header.app-summary-card__header a').text).to eq('Remove condition')
      end
    end
  end
end
