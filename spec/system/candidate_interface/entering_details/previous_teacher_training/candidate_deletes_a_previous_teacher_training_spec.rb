require 'rails_helper'

RSpec.describe 'Previous teacher training' do
  include CandidateHelper

  scenario 'Candidate deletes a previous teacher trainings' do
    given_i_am_signed_in_with_one_login
    and_there_are_providers_to_select
    and_a_previous_teacher_training_exists
    and_i_am_on_the_application_details_page

    when_i_click('Previous teacher training')
    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_the_existing_previous_teacher_training_details

    when_i_click('Delete')
    then_i_see_the_do_you_want_to_delete_page

    when_i_click('Yes, delete previous teacher training')
    then_i_see_the_previous_teacher_training_was_deleted
    and_i_am_on_the_application_details_page
    and_the_previous_teacher_training_is_incomplete
  end

  def and_there_are_providers_to_select
    create(:course, :open, provider: create(:provider, name: 'test provider'))
    create(:course, :open, provider: create(:provider, name: 'another provider'))
  end

  def and_a_previous_teacher_training_exists
    @existing_previous_teacher_training = create(
      :previous_teacher_training,
      :published,
      application_form: @current_candidate.current_application,
    )
    @current_candidate.current_application.update!(
      previous_teacher_training_completed: true,
      previous_teacher_training_completed_at: Time.zone.now,
    )
  end

  def and_i_am_on_the_application_details_page
    visit candidate_interface_details_path
  end

  def then_i_am_on_the_previous_teacher_trainings_page
    expect(page).to have_element(:h1, text: 'Check your previous teacher training', class: 'govuk-heading-xl')
    expect(page).to have_current_path(
      candidate_interface_previous_teacher_trainings_path, ignore_query: true
    )
    expect(page).to have_link(
      'Add another previous teacher training course',
      href: create_candidate_interface_previous_teacher_trainings_path(
        candidate_interface_previous_teacher_trainings_start_form: { started: 'yes' },
      ),
    )
    within('#started-declaration') do
      expect(page).to have_element(
        :dt,
        text: 'Have you started an initial teacher training (ITT) course in England before?',
        class: 'govuk-summary-list__key',
      )
      expect(page).to have_element(:dd, text: 'Yes', class: 'govuk-summary-list__value')
    end
  end

  def and_i_see_the_existing_previous_teacher_training_details
    within("#previous-teacher-training-#{@existing_previous_teacher_training.id}") do
      within('.app-summary-card__header') do
        expect(page).to have_element('h2', text: @existing_previous_teacher_training.provider_name)
      end
      within('.app-summary-card__body') do
        expect(page).to have_element(
          :div,
          text: "Name of the training provider #{@existing_previous_teacher_training.provider_name}",
          class: 'govuk-summary-list__row',
        )
        expect(page).to have_element(
          :div,
          text: "Training dates #{@existing_previous_teacher_training.formatted_dates}",
          class: 'govuk-summary-list__row',
        )
        expect(page).to have_element(
          :div,
          text: "Details #{@existing_previous_teacher_training.details}",
          class: 'govuk-summary-list__row',
        )
      end
    end
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :then_i_click, :when_i_click

  def then_i_see_the_do_you_want_to_delete_page
    expect(page).to have_element(
      :span,
      text: 'Previous teacher training',
      class: 'govuk-caption-l',
    )
    expect(page).to have_element(
      :h1,
      text: 'Are you sure you want to delete this previous teacher training?',
      class: 'govuk-heading-l',
    )

    within('.app-summary-card__body') do
      expect(page).to have_element(
        :div,
        text: "Name of the training provider #{@existing_previous_teacher_training.provider_name}",
        class: 'govuk-summary-list__row',
      )
      expect(page).to have_element(
        :div,
        text: "Training dates #{@existing_previous_teacher_training.formatted_dates}",
        class: 'govuk-summary-list__row',
      )
      expect(page).to have_element(
        :div,
        text: "Details #{@existing_previous_teacher_training.details}",
        class: 'govuk-summary-list__row',
      )
    end

    expect(page).to have_button('Yes, delete previous teacher training')
  end

  def then_i_see_the_previous_teacher_training_was_deleted
    within('.govuk-notification-banner--success') do
      expect(page).to have_content(
        "Previous teacher training for #{@existing_previous_teacher_training.provider_name} was deleted.",
      )
    end
  end

  def and_the_previous_teacher_training_is_incomplete
    expect(page).to have_css('#previous-teacher-training-badge-id', text: 'Incomplete')
  end
end
