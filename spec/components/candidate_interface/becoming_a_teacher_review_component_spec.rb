require 'rails_helper'

RSpec.describe CandidateInterface::BecomingATeacherReviewComponent do
  let(:application_form) { build_stubbed(:completed_application_form) }

  context 'when becoming a teacher is editable' do
    context 'when the candidate is on the old personal statement' do
      before do
        FeatureFlag.deactivate(:one_personal_statement)
      end

      it 'renders SummaryCardComponent with valid becoming a teacher' do
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include(application_form.becoming_a_teacher)
        expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.personal_statement.becoming_a_teacher.change_action')}")
      end
    end

    context 'when the candidate is on the new perdsonal statement' do
      before do
        FeatureFlag.activate(:one_personal_statement)
      end

      it 'renders SummaryCardComponent with valid personal statement' do
        new_application_form = build_stubbed(:completed_application_form, created_at: ApplicationForm::SINGLE_PERSONAL_STATEMENT_FROM + 1.day)
        result = render_inline(described_class.new(application_form: new_application_form))

        expect(result.text).to include(new_application_form.becoming_a_teacher)
        expect(result.css('.govuk-summary-list__actions').text).to include('Change personal statement')
      end
    end
  end

  context 'when becoming a teacher is not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form:, editable: false))

      expect(result.css('.govuk-summary-list__actions').text).not_to include("Change #{t('application_form.personal_statement.becoming_a_teacher.change_action')}")
    end
  end

  describe 'submitting app' do
    let(:result) { render_inline(described_class.new(application_form:, submitting_application: true)) }

    context 'section not complete' do
      before { application_form.becoming_a_teacher_completed = false }

      context 'when review is pending' do
        before { allow(application_form).to receive(:review_pending?).with(:becoming_a_teacher).and_return(true) }

        it 'shows review-related messaging' do
          expect(result.text).to include(t('review_application.becoming_a_teacher.not_reviewed'))
        end
      end

      context 'when review is not pending' do
        before { allow(application_form).to receive(:review_pending?).with(:becoming_a_teacher).and_return(false) }

        it 'shows section missing messaging' do
          expect(result.text).to include(t('review_application.becoming_a_teacher.incomplete'))
        end
      end
    end
  end
end
