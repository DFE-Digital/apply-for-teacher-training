require 'rails_helper'

RSpec.describe 'Previous teacher training' do
  include CandidateHelper

  scenario 'Candidate deletes a previous teacher trainings' do
    given_i_am_signed_in_with_one_login
    and_a_previous_teacher_training_exists
    and_i_am_on_the_application_details_page

    when_i_click('Previous teacher training')
    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_a_link_to_add_another_previous_teacher_training
    and_i_see_the_existing_previous_teacher_training_details

    when_i_click('Delete')
    then_i_see_the_do_you_want_to_delete_page

    when_i_click('Yes, delete previous teacher training')
    then_i_see_the_previous_teacher_training_was_deleted
    and_i_am_on_the_application_details_page
    and_the_previous_teacher_training_is_incomplete
  end

  scenario 'Candidate can not delete a previous teacher training once an application is submitted' do
    create_and_sign_in_candidate
    and_i_have_a_submitted_application_form
    and_a_previous_teacher_training_exists
    and_i_am_on_the_application_details_page

    when_i_click('Previous teacher training')
    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_the_existing_previous_teacher_training_details
    and_i_do_not_see_a_delete_link
    and_i_do_not_see_any_change_links

    when_i_visit_the_remove_page
    then_i_am_redirected_to_the_application_details_page
  end

  def and_there_are_providers_to_select
    create(:course, :open, provider: create(:provider, name: 'test provider'))
    create(:course, :open, provider: create(:provider, name: 'another provider'))
  end

  def and_i_have_a_submitted_application_form
    create(:application_form, :completed, submitted_application_choices_count: 1, candidate: current_candidate)
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
    within('#started-declaration') do
      expect(page).to have_element(
        :dt,
        text: 'Have you started an initial teacher training (ITT) course in England before?',
        class: 'govuk-summary-list__key',
      )
      expect(page).to have_element(:dd, text: 'Yes', class: 'govuk-summary-list__value')
    end
  end

  def and_i_see_a_link_to_add_another_previous_teacher_training
    expect(page).to have_link(
      'Add another previous teacher training course',
      href: create_candidate_interface_previous_teacher_trainings_path(
        candidate_interface_previous_teacher_trainings_start_form: { started: 'yes' },
      ),
    )
  end

  def and_i_see_the_existing_previous_teacher_training_details
    summary_list = [
      {
        label: 'Name of the training provider',
        value: @existing_previous_teacher_training.provider_name,
      },
      {
        label: 'Training dates',
        value: @existing_previous_teacher_training.formatted_dates,
      },
      {
        label: 'Details',
        value: @existing_previous_teacher_training.details,
      },
    ]

    within("#previous-teacher-training-#{@existing_previous_teacher_training.id}") do
      expect(page).to have_element('h2', text: @existing_previous_teacher_training.provider_name, class: 'govuk-summary-card__title')
      within('.govuk-summary-card__content') do
        summary_list.each_with_index do |item, index|
          within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
            expect(page).to have_content(item[:label])
            expect(page).to have_content(item[:value])
          end
        end
      end
    end
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :then_i_click, :when_i_click

  def then_i_see_the_do_you_want_to_delete_page
    summary_list = [
      {
        label: 'Name of the training provider',
        value: @existing_previous_teacher_training.provider_name,
      },
      {
        label: 'Training dates',
        value: @existing_previous_teacher_training.formatted_dates,
      },
      {
        label: 'Details',
        value: @existing_previous_teacher_training.details,
      },
    ]

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

    within("#previous-teacher-training-#{@existing_previous_teacher_training.id}") do
      expect(page).not_to have_element('h2', text: @existing_previous_teacher_training.provider_name, class: 'govuk-summary-card__title')
      within('.govuk-summary-list') do
        summary_list.each_with_index do |item, index|
          within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
            expect(page).to have_content(item[:label])
            expect(page).to have_content(item[:value])
          end
        end
      end
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

  def and_i_do_not_see_a_delete_link
    expect(page).to have_no_link('Delete', href: remove_candidate_interface_previous_teacher_training_path(@existing_previous_teacher_training))
  end

  def and_i_do_not_see_any_change_links
    expect(page).to have_no_link('Change the name of the training provider')
    expect(page).to have_no_link('Change training dates')
    expect(page).to have_no_link('Change details of your previous teacher training')
  end

  def when_i_visit_the_remove_page
    visit remove_candidate_interface_previous_teacher_training_path(@existing_previous_teacher_training)
  end

  def then_i_am_redirected_to_the_application_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end
end
