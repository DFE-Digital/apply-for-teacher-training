require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  it 'Candidate selects a course that is closed' do
    given_i_am_signed_in
    and_the_course_has_been_closed

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    then_i_see_a_course_and_its_description

    and_i_choose_a_course_that_has_been_closed
    then_i_be_on_the_application_choice_closed_page
    and_i_see_that_i_can_apply_to_a_different_provider

    when_the_provider_adds_more_vacancies
    then_i_see_that_i_can_apply_to_another_course

    when_i_click_back
    then_i_be_on_the_course_choice_page
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    create_and_sign_in_candidate(candidate: @candidate)
  end

  def and_the_course_has_been_closed
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open, application_status: 'closed', name: 'Primary', code: '2XT2', provider: @provider)
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_on_course_choices
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
  end

  def then_i_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description_to_s)
  end

  def and_i_choose_a_course_that_has_been_closed
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end

  def then_i_be_on_the_application_choice_closed_page
    expect(page).to have_content('Unfortunately, you cannot apply to Primary (2XT2) because it is closed')
  end

  def and_i_see_that_i_can_apply_to_a_different_provider
    expect(page).to have_no_content('apply to a different course offered by Gorse SCITT')
    expect(page).to have_content('You can apply to a different training provider.')
  end

  def when_the_provider_adds_more_vacancies
    create(:course, :open, :with_course_options, provider: @provider)
  end

  def then_i_see_that_i_can_apply_to_another_course
    visit current_path

    expect(page).to have_content('apply to a different course offered by Gorse SCITT')
    expect(page).to have_content('apply to a different training provider')
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_be_on_the_course_choice_page
    expect(page.current_url).to end_with(candidate_interface_course_choices_which_course_are_you_applying_to_path(provider_id: @provider.id))
  end
end
