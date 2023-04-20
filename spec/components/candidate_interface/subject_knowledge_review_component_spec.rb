require 'rails_helper'

RSpec.describe CandidateInterface::SubjectKnowledgeReviewComponent, type: :component do
  let(:application_form) { build_stubbed(:completed_application_form) }

  context 'when subject knowledge is editable' do
    it 'renders SummaryCardComponent with valid becoming a teacher' do
      render_inline(described_class.new(application_form:))

      expect(page.text).to include(application_form.subject_knowledge)
      expect(page).to have_link('Edit your answer')
    end
  end

  context 'when subject knowledge is not editable' do
    it 'renders component without an edit link' do
      render_inline(described_class.new(application_form:, editable: false))

      expect(page).not_to have_link('Edit your answer')
    end
  end

  describe 'submitting app' do
    context 'section not complete' do
      before do
        application_form.subject_knowledge_completed = false
      end

      context 'when review is pending' do
        before do
          allow(application_form).to receive(:review_pending?).with(:subject_knowledge).and_return(true)
          render_inline(described_class.new(application_form:, submitting_application: true))
        end

        it 'shows review-related messaging' do
          expect(page.text).to include(t('review_application.subject_knowledge.not_reviewed'))
        end
      end

      context 'when review is not pending' do
        before do
          allow(application_form).to receive(:review_pending?).with(:subject_knowledge).and_return(false)
          render_inline(described_class.new(application_form:, submitting_application: true))
        end

        it 'shows section missing messaging' do
          expect(page.text).to include(t('review_application.subject_knowledge.incomplete'))
        end
      end
    end
  end
end
