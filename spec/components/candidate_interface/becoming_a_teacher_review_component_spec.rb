require 'rails_helper'

RSpec.describe CandidateInterface::BecomingATeacherReviewComponent, type: :component do
  let(:application_form) { build_stubbed(:completed_application_form) }

  context 'when becoming a teacher is editable' do
    it 'renders SummaryCardComponent with valid personal statement' do
      new_application_form = build_stubbed(:completed_application_form)
      render_inline(described_class.new(application_form: new_application_form))

      expect(page).to have_text(new_application_form.becoming_a_teacher)
      expect(page).to have_link('Edit your personal statement')
    end
  end

  context 'when becoming a teacher is not editable' do
    it 'renders component without an edit link' do
      render_inline(described_class.new(application_form:, editable: false))

      expect(page).to have_no_link('Edit your personal statement')
    end
  end

  describe 'submitting app' do
    context 'section not complete' do
      before { application_form.becoming_a_teacher_completed = false }

      context 'when review is pending' do
        before do
          allow(application_form).to receive(:review_pending?).with(:becoming_a_teacher).and_return(true)
          render_inline(described_class.new(application_form:, submitting_application: true))
        end

        it 'shows review-related messaging' do
          expect(page).to have_text(t('review_application.becoming_a_teacher.not_reviewed'))
        end
      end

      context 'when review is not pending' do
        before do
          allow(application_form).to receive(:review_pending?).with(:becoming_a_teacher).and_return(false)
          render_inline(described_class.new(application_form:, submitting_application: true))
        end

        it 'shows section missing messaging' do
          expect(page).to have_text(t('review_application.becoming_a_teacher.incomplete'))
        end
      end
    end
  end
end
