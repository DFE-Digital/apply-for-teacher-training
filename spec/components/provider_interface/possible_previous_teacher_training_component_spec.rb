require 'rails_helper'

RSpec.describe ProviderInterface::PossiblePreviousTeacherTrainingComponent do
  let(:possible_previous_teacher_trainings) { [] }
  let(:rendered_component) { render_inline(component) }
  let(:component) { described_class.new(possible_previous_teacher_trainings:) }

  describe '.render' do
    subject(:rendered) { component.render? }

    context 'when no possible previous teacher trainings are given' do
      it 'does not render' do
        expect(rendered).to be(false)
      end
    end

    context 'when one possible previous teacher training is given' do
      let(:possible_previous_teacher_training) do
        build(
          :possible_previous_teacher_training,
          provider_name: "The London Provider",
          started_on: Date.parse("01/01/2024"),
          ended_on: Date.parse("01/07/2024"),
        )
      end
      let(:possible_previous_teacher_trainings) do
        [possible_previous_teacher_training]
      end

      it 'renders the possible previous teacher training' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
          :div,
          text: 'This candidate may have previously started the below course',
          class: 'govuk-warning-text',
        )

        expect(rendered_component).to have_element(
          :h3,
          text: 'The London Provider',
          class: 'govuk-summary-card__title',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Name of the training provider The London Provider",
          class: 'govuk-summary-list__row',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Training dates From January 2024 to July 2024",
          class: 'govuk-summary-list__row',
        )

        expect(rendered_component).to have_element(
          :span,
          text: 'Why we think they may have trained before',
          class: 'govuk-details__summary-text',
        )
        expect(rendered_component).to have_text(
          'A candidate with the same first name, last name and date of birth previously started the course above.',
        )
      end
    end

    context 'when many possible previous teacher trainings are given' do
      let(:possible_previous_teacher_training_2023) do
        build(
          :possible_previous_teacher_training,
          provider_name: "The London Provider",
          started_on: Date.parse("01/01/2023"),
          ended_on: Date.parse("01/07/2023"),
          )
      end
      let(:possible_previous_teacher_training_2024) do
        build(
          :possible_previous_teacher_training,
          provider_name: "The Manchester Provider",
          started_on: Date.parse("01/01/2024"),
          ended_on: Date.parse("01/07/2024"),
          )
      end
      let(:possible_previous_teacher_training_2025) do
        build(
          :possible_previous_teacher_training,
          provider_name: "The Liverpool Provider",
          started_on: Date.parse("01/01/2025"),
          ended_on: Date.parse("01/07/2025"),
          )
      end
      let(:possible_previous_teacher_trainings) do
        [
          possible_previous_teacher_training_2023,
          possible_previous_teacher_training_2024,
          possible_previous_teacher_training_2025,
        ]
      end

      it 'renders the possible previous teacher trainings' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
          :div,
          text: 'This candidate may have previously started the below courses',
          class: 'govuk-warning-text',
        )

        expect(rendered_component).to have_element(
          :h3,
          text: 'The London Provider',
          class: 'govuk-summary-card__title',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Name of the training provider The London Provider",
          class: 'govuk-summary-list__row',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Training dates From January 2023 to July 2023",
          class: 'govuk-summary-list__row',
        )

        expect(rendered_component).to have_element(
          :h3,
          text: 'The Manchester Provider',
          class: 'govuk-summary-card__title',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Name of the training provider The Manchester Provider",
          class: 'govuk-summary-list__row',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Training dates From January 2024 to July 2024",
          class: 'govuk-summary-list__row',
        )

        expect(rendered_component).to have_element(
          :h3,
          text: 'The Liverpool Provider',
          class: 'govuk-summary-card__title',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Name of the training provider The Liverpool Provider",
          class: 'govuk-summary-list__row',
        )
        expect(rendered_component).to have_element(
          :div,
          text: "Training dates From January 2025 to July 2025",
          class: 'govuk-summary-list__row',
        )

        expect(rendered_component).to have_element(
          :span,
          text: 'Why we think they may have trained before',
          class: 'govuk-details__summary-text',
        )
        expect(rendered_component).to have_text(
           'A candidate with the same first name, last name and date of birth previously started the courses above.',
        )
      end
    end
  end
end
