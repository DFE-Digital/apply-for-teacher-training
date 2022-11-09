require 'rails_helper'

RSpec.describe RejectionReasons::RejectionFeedbackSurveyComponent do
  describe 'rendered component' do
    let(:application_choice) { create(:application_choice, :with_rejection) }

    context 'when no response has been provided' do
      it 'renders the survey button' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include('Is this feedback helpful?')
      end
    end

    context 'when the feedback was not helpful' do
      it 'renders the correct text' do
        ProvideRejectionFeedback.new(application_choice, false).call
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include('You said that this feedback is not helpful.')
      end
    end

    context 'when the feedback was helpful' do
      it 'renders the correct text' do
        ProvideRejectionFeedback.new(application_choice, true).call
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include('You said that this feedback is helpful.')
      end
    end

    context 'when the application choice is not rejected' do
      let(:application_choice) { create(:application_choice, :withdrawn) }

      it 'does not render the feedback button' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).not_to include('Is this feedback helpful?')
      end
    end
  end
end
