require 'rails_helper'

RSpec.describe 'Edit previous teacher training' do
  include CandidateHelper

  scenario 'Candidate edits started' do
    given_i_am_signed_in_with_one_login
    and_the_necessary_data_is_in_place
    when_i_go_to_the_details_page
    and_the_previous_teacher_training_is_completed
    when_i_click('Previous teacher training')
    and_i_click('Change whether you started a teacher training course before')

    then_i_am_on_the_start_page
    when_i_choose('No')
    and_i_click('Continue')

    then_i_am_on_the_review_page_with_started_no
    when_i_choose('No, I’ll come back to it later')
    and_i_click('Continue')
    and_the_previous_teacher_training_is_not_completed
    and_the_previous_teacher_training_id_is_changed
  end

  scenario 'Candidate edits provider_name' do
    given_i_am_signed_in_with_one_login
    and_the_necessary_data_is_in_place
    when_i_go_to_the_details_page
    and_the_previous_teacher_training_is_completed
    when_i_click('Previous teacher training')
    and_i_click('Change the name of the training provider')

    then_i_am_on_the_provider_name_page
    when_i_input_provider_name
    and_i_click('Continue')

    then_i_am_on_the_review_page
    when_i_choose('No, I’ll come back to it later')
    and_i_click('Continue')
    and_the_previous_teacher_training_is_not_completed
    and_the_previous_teacher_training_id_is_changed
  end

  scenario 'Candidate edits dates' do
    given_i_am_signed_in_with_one_login
    and_the_necessary_data_is_in_place
    when_i_go_to_the_details_page
    and_the_previous_teacher_training_is_completed
    when_i_click('Previous teacher training')
    and_i_click('Change training dates')

    then_i_am_on_the_dates_page
    when_i_input_training_dates
    and_i_click('Continue')

    then_i_am_on_the_review_page
    when_i_choose('No, I’ll come back to it later')
    and_i_click('Continue')
    and_the_previous_teacher_training_is_not_completed
    and_the_previous_teacher_training_id_is_changed
  end

  scenario 'Candidate edits details' do
    given_i_am_signed_in_with_one_login
    and_the_necessary_data_is_in_place
    when_i_go_to_the_details_page
    and_the_previous_teacher_training_is_completed
    when_i_click('Previous teacher training')
    and_i_click('Change details of your previous teacher training')

    then_i_am_on_the_details_page
    when_i_input_details
    and_i_click('Continue')

    then_i_am_on_the_review_page
    when_i_choose('No, I’ll come back to it later')
    and_i_click('Continue')
    and_the_previous_teacher_training_is_not_completed
    and_the_previous_teacher_training_id_is_changed
  end

  def and_the_necessary_data_is_in_place
    provider = create(:provider, name: 'test provider')
    provider_2 = create(:provider)
    create(:course, :open, provider:)

    @application_form = @current_candidate.current_application
    @application_form.update(
      previous_teacher_training_completed: true,
      previous_teacher_training_completed_at: Time.zone.now,
    )

    @previous_teacher_training = create(
      :previous_teacher_training,
      status: 'published',
      application_form: @application_form,
      provider_name: provider_2.name,
      provider: provider_2,
    )
    create(:course, :open, provider: provider_2)
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :and_i_click, :when_i_click

  def when_i_choose(option)
    choose(option)
  end

  def then_i_see_an_error(error)
    expect(page).to have_content(error).twice
  end

  def then_i_am_on_the_start_page
    expect(page).to have_current_path(
      edit_candidate_interface_previous_teacher_trainings_path(
        @previous_teacher_training,
      ), ignore_query: true
    )
  end

  def then_i_am_on_the_provider_name_page
    expect(page).to have_current_path(
      new_candidate_interface_previous_teacher_training_name_path(@previous_teacher_training),
      ignore_query: true,
    )
    expect(page).to have_select(
      'Name of the training provider',
      selected: @previous_teacher_training.provider_name,
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
    fill_in('Give details about any previous teacher training courses', with: 'some details')
  end

  def then_i_am_on_the_review_page
    expect(page).to have_content('Check your previous teacher training')

    published_record = @application_form.published_previous_teacher_training
    summary_list = [
      {
        label: 'Have you started an initial teacher training (ITT) course in England before?',
        value: published_record.started.capitalize,
      },
      {
        label: 'Name of the training provider',
        value: published_record.provider_name,
      },
      {
        label: 'Training dates',
        value: "From #{published_record.started_at.to_fs(:month_and_year)} " \
               "to #{published_record.ended_at.to_fs(:month_and_year)}",
      },
      {
        label: 'Details',
        value: published_record.details,
      },
    ]

    summary_list.each_with_index do |item, index|
      within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(item[:label])
        expect(page).to have_content(item[:value])
      end
    end
  end

  def then_i_am_on_the_review_page_with_started_no
    expect(page).to have_content('Check your previous teacher training')

    published_record = @application_form.published_previous_teacher_training
    summary_list = [
      {
        label: 'Have you started an initial teacher training (ITT) course in England before?',
        value: published_record.started.capitalize,
      },
    ]

    summary_list.each_with_index do |item, index|
      within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(item[:label])
        expect(page).to have_content(item[:value])
      end
    end
  end

  def and_the_previous_teacher_training_id_is_changed
    expect(@application_form.published_previous_teacher_training.id).not_to eq(@previous_teacher_training.id)
  end

  def then_i_am_on_the_application_details_page
    expect(page).to have_current_path(candidate_interface_details_path, ignore_query: true)
  end

  def when_i_go_to_the_details_page
    visit candidate_interface_details_path
  end

  def and_the_previous_teacher_training_is_completed
    expect(page).to have_css('#previous-teacher-training-badge-id', text: 'Completed')
  end

  def and_the_previous_teacher_training_is_not_completed
    expect(page).to have_css('#previous-teacher-training-badge-id', text: 'Incomplete')
  end
end
