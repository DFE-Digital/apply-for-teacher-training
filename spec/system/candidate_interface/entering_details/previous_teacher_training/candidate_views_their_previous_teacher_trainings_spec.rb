require 'rails_helper'

RSpec.describe 'Previous teacher training' do
  include CandidateHelper

  scenario 'Candidate views their previous teacher trainings' do
    given_i_am_signed_in_with_one_login
    and_previous_teacher_trainings_exists
    and_i_am_on_the_application_details_page

    when_i_click('Previous teacher training')
    then_i_am_on_the_previous_teacher_trainings_page
    and_i_see_the_existing_previous_teacher_training_details
    and_i_do_not_see_the_previous_teacher_trainings_for_other_candidate
  end

  def and_there_are_providers_to_select
    create(:course, :open, provider: create(:provider, name: 'test provider'))
    create(:course, :open, provider: create(:provider, name: 'another provider'))
  end

  def and_previous_teacher_trainings_exists
    @existing_previous_teacher_training = create(
      :previous_teacher_training,
      :published,
      application_form: @current_candidate.current_application,
    )
    @current_candidate.current_application.update!(
      previous_teacher_training_completed: true,
      previous_teacher_training_completed_at: Time.zone.now,
    )

    @another_previous_teacher_training = create(
      :previous_teacher_training,
      :published,
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

  def and_i_do_not_see_the_previous_teacher_trainings_for_other_candidate
    expect(page).not_to have_element(:div, id: "previous-teacher-training-#{@another_previous_teacher_training.id}")
    expect(page).not_to have_element(:dd, text: @another_previous_teacher_training.provider_name, class: 'govuk-summary-list__value')
    expect(page).not_to have_element(:dd, text: @another_previous_teacher_training.details, class: 'govuk-summary-list__value')
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :then_i_click, :when_i_click
end
