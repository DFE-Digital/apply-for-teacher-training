require 'rails_helper'

RSpec.describe 'Previous teacher training' do
  include CandidateHelper

  scenario 'Candidate adds previous teacher training' do
    given_i_am_signed_in_with_one_login
    and_there_is_a_provider_to_select
    when_i_click('Previous teacher training')

    then_i_am_on_the_start_page
    when_i_click('Continue')
    then_i_see_an_error('Select whether you have started a teacher training course before')
    when_i_choose('Yes')
    then_i_click('Continue')
    and_previous_teacher_training_created

    then_i_am_on_the_provider_name_page
    when_i_click('Continue')
    then_i_see_an_error('Enter the name of the training provider')
    when_i_input_provider_name
    then_i_click('Continue')

    then_i_am_on_the_dates_page
    when_i_click('Continue')
    then_i_see_an_error('Enter the date that you started the training course')
    then_i_see_an_error('Enter the date that you left the training course')
    when_i_input_training_dates
    then_i_click('Continue')

    then_i_am_on_the_details_page
    when_i_click('Continue')
    then_i_see_an_error('Enter details about your previous teacher training courses')
    when_i_input_details
    then_i_click('Continue')

    then_i_am_on_the_review_page
    when_i_click('Continue')
    then_i_see_an_error('Select whether you have completed this section')
    when_i_choose('Yes, I have completed this section')
    then_i_click('Continue')

    then_i_am_on_the_application_details_page
    and_the_previous_teacher_training_is_completed
  end

  def and_there_is_a_provider_to_select
    provider = create(:provider, name: 'test provider')
    create(:course, :open, provider:)
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

  def then_i_am_on_the_review_page
    expect(page).to have_current_path(
      candidate_interface_previous_teacher_trainings_path,
      ignore_query: true,
    )

    expect(page).to have_content('Check your previous teacher training')

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

    within('#started-declaration') do
      expect(page).to have_element(
        :dt,
        text: 'Have you started an initial teacher training (ITT) course in England before?',
        class: 'govuk-summary-list__key',
      )
      expect(page).to have_element(
        :dd,
        text: 'Yes',
        class: 'govuk-summary-list__value',
      )
    end

    within("#previous-teacher-training-#{@previous_teacher_training.id}") do
      summary_list.each_with_index do |item, index|
        within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
          expect(page).to have_content(item[:label])
          expect(page).to have_content(item[:value])
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
end
