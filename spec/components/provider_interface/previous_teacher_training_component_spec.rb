require 'rails_helper'

RSpec.describe ProviderInterface::PreviousTeacherTrainingComponent do
  let(:application_form) { create(:application_form) }
  let(:rendered_component) { render_inline(described_class.new(application_form:)) }
  let(:component) { described_class.new(application_form:) }

  describe '.render' do
    subject(:rendered) { component.render? }

    context 'when the application has published previous teacher trainings' do
      let!(:previous_teacher_training) { create(:previous_teacher_training, :published, application_form:) }

      it 'renders the component' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(:h3, text: 'Previous teacher training')
        # PreviousTeacherTraining::StartedDeclarationComponent
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

        # PreviousTeacherTraining::ListComponent

        expect(rendered_component).to have_element(
          :dt,
          text: 'Name of the training provider',
          class: 'govuk-summary-list__key',
        )
        expect(rendered_component).to have_element(
          :dd,
          text: previous_teacher_training.provider_name,
          class: 'govuk-summary-list__value',
        )
        expect(rendered_component).to have_element(
          :dt,
          text: 'Training dates',
          class: 'govuk-summary-list__key',
        )
        expect(rendered_component).to have_element(
          :dd,
          text: previous_teacher_training.formatted_dates,
          class: 'govuk-summary-list__value',
        )
        expect(rendered_component).to have_element(
          :dt,
          text: 'Details',
          class: 'govuk-summary-list__key',
        )
        expect(rendered_component).to have_element(
          :dd,
          text: previous_teacher_training.details,
          class: 'govuk-summary-list__value',
        )
      end
    end

    context 'when the application has draft previous teacher trainings' do
      before do
        create(:previous_teacher_training, application_form:)
      end

      it 'renders the component' do
        expect(rendered).to be(false)
      end
    end

    context 'when the application does not have previous teacher trainings' do
      it 'does not render the component' do
        expect(rendered).to be(false)
      end
    end
  end

  describe '.previous_teacher_trainings' do
    let!(:published_previous_teacher_trainings) do
      create_list(:previous_teacher_training, 3, :published, application_form: application_form)
    end
    let(:draft_previous_teacher_trainings) do
      create(:previous_teacher_training, application_form: application_form)
    end

    before { draft_previous_teacher_trainings }

    it 'returns the application forms published previous teacher trainings' do
      expect(component.previous_teacher_trainings).to match_array(published_previous_teacher_trainings)
    end
  end
end
