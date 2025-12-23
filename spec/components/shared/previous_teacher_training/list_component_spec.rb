require 'rails_helper'

RSpec.describe PreviousTeacherTraining::ListComponent do
  let(:application_form) { create(:application_form) }

  describe 'renders the component' do
    subject(:rendered_component) do
      render_inline(described_class.with_collection(previous_teacher_trainings, card:, actions:))
    end

    let(:actions) { false }
    let(:card) { true }

    context 'when the application form has only one published previous teacher training' do
      let(:previous_teacher_trainings) do
        create_list(:previous_teacher_training, 1, application_form:)
      end
      let(:previous_teacher_training) { previous_teacher_trainings.last }

      it 'renders only one previous teacher training' do
        previous_teacher_training_card_displayed(previous_teacher_training)
      end
    end

    context 'when the application form has multiple previous teacher trainings' do
      let(:previous_teacher_trainings) do
        create_list(:previous_teacher_training, 3, application_form:)
      end

      it 'renders all of the previous teacher trainings' do
        previous_teacher_trainings.each do |previous_teacher_training|
          previous_teacher_training_card_displayed(previous_teacher_training)
        end
      end
    end

    context 'when header is false' do
      let(:card) { false }

      let(:previous_teacher_trainings) do
        create_list(:previous_teacher_training, 1, application_form:)
      end
      let(:previous_teacher_training) { previous_teacher_trainings.last }

      it 'renders the previous teacher training card without a header' do
        previous_teacher_training_id = "previous-teacher-training-#{previous_teacher_training.id}"
        expect(rendered_component).to have_element(:div, id: previous_teacher_training_id)

        previous_teacher_training_card = rendered_component.css("##{previous_teacher_training_id}")
        expect(previous_teacher_training_card).not_to have_element(:div, class: 'govuk-summary-card')
        expect(previous_teacher_training_card).not_to have_element(
          :h2,
          text: previous_teacher_training.provider_name,
          class: 'govuk-summary-card__title',
        )
      end
    end

    context 'when actions is true' do
      let(:actions) { true }
      let(:previous_teacher_trainings) do
        create_list(:previous_teacher_training, 1, application_form:)
      end
      let(:previous_teacher_training) { previous_teacher_trainings.last }

      it 'renders the previous teacher training card with actions' do
        previous_teacher_training_id = "previous-teacher-training-#{previous_teacher_training.id}"
        previous_teacher_training_card = rendered_component.css("##{previous_teacher_training_id}")
        expect(previous_teacher_training_card).to have_link(
          'Delete',
          href: "/candidate/previous-teacher-training/#{previous_teacher_training.id}/remove",
        )
        expect(previous_teacher_training_card).to have_link(
          'Change the name of the training provider',
          href: "/candidate/previous-teacher-training/#{previous_teacher_training.id}/provider-name/new?return_to=review",
        )
        expect(previous_teacher_training_card).to have_link(
          'Change training dates',
          href: "/candidate/previous-teacher-training/#{previous_teacher_training.id}/training-dates/new?return_to=review",
        )
        expect(previous_teacher_training_card).to have_link(
          'Change details of your previous teacher training',
          href: "/candidate/previous-teacher-training/#{previous_teacher_training.id}/training-details/new?return_to=review",
        )
      end
    end
  end

  def previous_teacher_training_card_displayed(previous_teacher_training)
    previous_teacher_training_id = "previous-teacher-training-#{previous_teacher_training.id}"
    expect(rendered_component).to have_element(:div, id: previous_teacher_training_id)

    previous_teacher_training_card = rendered_component.css("##{previous_teacher_training_id}")
    expect(previous_teacher_training_card).to have_element(:div, class: 'govuk-summary-card')
    expect(previous_teacher_training_card).to have_element(
      :h2,
      text: previous_teacher_training.provider_name,
      class: 'govuk-summary-card__title',
    )

    expect(previous_teacher_training_card).to have_element(
      :div,
      text: "Name of the training provider #{previous_teacher_training.provider_name}",
      class: 'govuk-summary-list__row',
    )
    expect(previous_teacher_training_card).to have_element(
      :div,
      text: "Training dates #{previous_teacher_training.formatted_dates}",
      class: 'govuk-summary-list__row',
    )
    expect(previous_teacher_training_card).to have_element(
      :div,
      text: "Details #{previous_teacher_training.details}",
      class: 'govuk-summary-list__row',
    )
  end
end
