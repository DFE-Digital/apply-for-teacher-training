require 'rails_helper'

RSpec.describe CandidateInterface::RejectionReasons::RejectionFeedbackSurveyComponent do
  describe 'rendered component' do
    let(:application_choice) { create(:application_choice, :rejected) }

    context 'when no response has been provided' do
      it 'renders the survey button' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include(I18n.t('rejection_feedback_survey.label'))
      end
    end

    context 'when the feedback was not helpful' do
      it 'renders the correct text' do
        ProvideRejectionFeedback.new(application_choice, false).call
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include(I18n.t('rejection_feedback_survey.response.not_helpful'))
      end
    end

    context 'when the feedback was helpful' do
      it 'renders the correct text' do
        ProvideRejectionFeedback.new(application_choice, true).call
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include(I18n.t('rejection_feedback_survey.response.helpful'))
      end
    end
  end
end
