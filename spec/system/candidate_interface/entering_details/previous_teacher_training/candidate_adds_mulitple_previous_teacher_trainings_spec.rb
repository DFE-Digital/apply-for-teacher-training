require 'rails_helper'

RSpec.describe 'Previous teacher training' do
  include CandidateHelper

  scenario 'Candidate adds multiple previous teacher trainings' do
    given_i_am_signed_in_with_one_login
    and_there_are_providers_to_select
    and_a_previous_teacher_training_exists
    and_i_am_on_the_application_details_page

    when_i_click('Previous teacher training')
    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_a_link_to_add_another_previous_teacher_training
    and_i_see_the_existing_previous_teacher_training_details

    when_i_click('Add another previous teacher training course')
    and_previous_teacher_training_created
    then_i_am_on_the_provider_name_page
    when_i_input_provider_name
    then_i_click('Continue')

    then_i_am_on_the_dates_page
    when_i_input_training_dates
    then_i_click('Continue')

    then_i_am_on_the_details_page
    when_i_input_details
    then_i_click('Continue')

    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_the_new_previous_teacher_training_details
    and_i_see_the_existing_previous_teacher_training_details
  end

  scenario 'Candidate can not add more previous teacher trainings once the application has been submitted' do
    create_and_sign_in_candidate
    and_i_have_a_submitted_application_form
    and_a_previous_teacher_training_exists
    and_i_am_on_the_application_details_page

    when_i_click('Previous teacher training')
    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_the_existing_previous_teacher_training_details
    and_i_do_not_see_a_link_to_add_another_previous_teacher_training

    when_i_visit_the_previous_teacher_training_start_page
    then_i_am_redirected_to_the_application_details_page

    when_i_visit_the_edit_provider_name_page_for_the_previous_teacher_training
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

  def when_i_choose(option)
    choose(option)
  end

  def then_i_see_an_error(error)
    expect(page).to have_content(error).twice
  end

  def then_i_am_on_the_start_page
    expect(page).to have_current_path(
      start_candidate_interface_previous_teacher_trainings_path, ignore_query: true
    )
  end

  def and_previous_teacher_training_created
    @previous_teacher_training = PreviousTeacherTraining.last
    expect(@previous_teacher_training).not_to be_nil
  end

  def then_i_am_on_the_provider_name_page
    expect(page).to have_current_path(
      new_candidate_interface_previous_teacher_training_name_path(@previous_teacher_training),
      ignore_query: true,
    )
  end

  def when_i_input_provider_name
    select 'test provider', from: 'Name of the training provider'
  end

  def then_i_am_on_the_dates_page
    expect(page).to have_current_path(
      new_candidate_interface_previous_teacher_training_date_path(@previous_teacher_training),
      ignore_query: true,
    )
  end

  def when_i_input_training_dates
    fill_in('candidate_interface_previous_teacher_trainings_dates_form[started_at(2i)]', with: 1)
    fill_in('candidate_interface_previous_teacher_trainings_dates_form[started_at(1i)]', with: 2005)
    fill_in('candidate_interface_previous_teacher_trainings_dates_form[ended_at(2i)]', with: 1)
    fill_in('candidate_interface_previous_teacher_trainings_dates_form[ended_at(1i)]', with: 2006)
  end

  def then_i_am_on_the_details_page
    expect(page).to have_current_path(
      new_candidate_interface_previous_teacher_training_detail_path(@previous_teacher_training),
      ignore_query: true,
    )
  end

  def when_i_input_details
    fill_in('Give details about any previous teacher training courses', with: 'details')
  end

  def and_i_see_the_new_previous_teacher_training_details
    summary_list = [
      {
        label: 'Name of the training provider',
        value: 'test provider',
      },
      {
        label: 'Training dates',
        value: 'From January 2005 to January 2006',
      },
      {
        label: 'Details',
        value: 'details',
      },
    ]

    within("#previous-teacher-training-#{@previous_teacher_training.id}") do
      expect(page).to have_element('h2', text: 'test provider', class: 'govuk-summary-card__title')
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

  def then_i_am_on_the_application_details_page
    expect(page).to have_current_path(candidate_interface_details_path, ignore_query: true)
  end

  def and_the_previous_teacher_training_is_completed
    expect(page).to have_css('#previous-teacher-training-badge-id', text: 'Completed')
  end

  def and_i_have_a_submitted_application_form
    create(:application_form, :completed, submitted_application_choices_count: 1, candidate: current_candidate)
  end

  def and_i_see_a_link_to_add_another_previous_teacher_training
    expect(page).to have_link(
      'Add another previous teacher training course',
      href: create_candidate_interface_previous_teacher_trainings_path(
        candidate_interface_previous_teacher_trainings_start_form: { started: 'yes' },
      ),
    )
  end

  def and_i_do_not_see_a_link_to_add_another_previous_teacher_training
    expect(page).to have_no_link(
      'Add another previous teacher training course',
      href: create_candidate_interface_previous_teacher_trainings_path(
        candidate_interface_previous_teacher_trainings_start_form: { started: 'yes' },
      ),
    )
  end

  def when_i_visit_the_previous_teacher_training_start_page
    visit start_candidate_interface_previous_teacher_trainings_path
  end

  def then_i_am_redirected_to_the_application_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def when_i_visit_the_edit_provider_name_page_for_the_previous_teacher_training; end
end
