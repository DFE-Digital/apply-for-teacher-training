require 'rails_helper'

RSpec.describe PreviousTeacherTraining::StartedDeclarationComponent do
  let(:application_form) { create(:application_form) }
  let(:rendered_component) { render_inline(described_class.new(application_form:)) }
  let(:component) { described_class.new(application_form:) }

  describe 'render?' do
    subject(:rendered) { component.render? }

    context 'when the application has published previous teacher trainings' do
      let!(:previous_teacher_training) { create(:previous_teacher_training, :published, application_form:, started:) }
      let(:started) { 'yes' }

      it 'renders the component' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
          :dt,
          text: 'Have you started an initial teacher training (ITT) course in England before?',
          class: 'govuk-summary-list__key',
        )
        expect(rendered_component).to have_element(
          :dd,
          text: 'Yes',
          class: 'govuk-summary-list__value',
        )
      end

      context 'when the previous teacher training started is no' do
        let(:started) { 'no' }

        it 'renders the component' do
          expect(rendered).to be(true)

          expect(rendered_component).to have_element(
            :dt,
            text: 'Have you started an initial teacher training (ITT) course in England before?',
            class: 'govuk-summary-list__key',
          )
          expect(rendered_component).to have_element(
            :dd,
            text: 'No',
            class: 'govuk-summary-list__value',
          )
        end
      end

      context 'when actions if true' do
        let(:rendered_component) { render_inline(described_class.new(application_form:, actions: true)) }

        it 'renders the component with a change link' do
          expect(rendered_component).to have_link(
            'Change whether you started a teacher training course before',
            href: "/candidate/previous-teacher-training/#{previous_teacher_training.id}/edit?return_to=review",
          )
        end
      end
    end

    context 'when the application has draft previous teacher trainings' do
      let!(:previous_teacher_training) { create(:previous_teacher_training, application_form:) }

      it 'does not render the component' do
        expect(rendered).to be(false)
      end
    end

    context 'when the application form has no previous teacher trainings' do
      it 'does not render the component' do
        expect(rendered).to be(false)
      end
    end
  end
end
