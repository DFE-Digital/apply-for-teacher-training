require 'rails_helper'

RSpec.describe ProviderInterface::SkeConditionsComponent do
  let(:application_choice) { create(:application_choice) }
  let(:editable) { true }
  let(:result) do
    render_inline(
      described_class.new(
        application_choice:,
        ske_condition:,
        editable: editable,
      ),
    )
  end

  context 'when a language ske condition' do
    let(:ske_condition) do
      SkeCondition.new(language: 'French', reason: 'some reason', length: '8')
    end

    it 'renders the selected SKE values' do
      expect(result.text).to include('SubjectFrench')
      expect(result.text).to include('Length8 weeks')
      expect(result.text).to include('Reasonsome reason')
    end
  end

  context 'when a standard ske condition' do
    let(:ske_condition) { SkeCondition.new(reason: 'some reason', length: '8') }

    it 'renders the subject from the course' do
      expect(result.text).to include("Subject#{application_choice.course_option.course.subjects.first.name}")
      expect(result.text).to include('Length8 weeks')
      expect(result.text).to include('Reasonsome reason')
    end
  end
end
