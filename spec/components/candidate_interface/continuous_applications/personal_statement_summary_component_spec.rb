require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::PersonalStatementSummaryComponent do
  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  context 'when showing full personal statement' do
    context 'when unsubmitted application' do
      let(:application_form) { create(:application_form, becoming_a_teacher: 'some text from application form') }
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

      it 'returns personal statement from application form' do
        expect(result.text).to include(application_form.becoming_a_teacher)
      end
    end

    context 'when submitted application' do
      let(:application_choice) { create(:application_choice, :awaiting_provider_decision, personal_statement: 'some text from application choice') }

      it 'returns personal statement from application choice' do
        expect(result.text).to include(application_choice.personal_statement)
      end
    end
  end

  context 'when showing short personal statement' do
    let(:short_personal_statement) { 'a' * 40 }
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, personal_statement: "#{short_personal_statement} remaining text")
    end

    it 'returns personal statement from application choice' do
      expect(result.text).to include(short_personal_statement)
    end
  end

  context 'when personal_statement is blank' do
    let(:application_form) { create(:application_form, becoming_a_teacher: nil) }
    let(:application_choice) do
      create(:application_choice, :unsubmitted, application_form:)
    end

    it 'renders nothing' do
      expect(result.text.chomp.strip).to eq('')
    end
  end
end
