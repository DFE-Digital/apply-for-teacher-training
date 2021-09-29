require 'rails_helper'

RSpec.feature 'Selecting a course not on Apply' do
  include CandidateHelper

  scenario 'Candidate selects a course choice that is not on Apply' do
    given_i_am_signed_in
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider_without_a_course
    then_i_see_that_i_should_apply_to_the_provider_on_ucas

    when_i_click_on_back
    and_i_choose_a_provider
    and_i_choose_another_course
    then_i_see_that_i_should_apply_to_the_course_on_ucas
    and_i_should_be_given_the_selected_training_provider_code_and_course_code
  end

  def given_i_am_not_signed_in; end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_there_are_course_options
    provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: provider)
    course1 = create(:course, name: 'Primary', code: '2XT2', provider: provider, exposed_in_find: true, open_on_apply: true)
    course2 = create(:course, name: 'Secondary', code: 'X123', provider: provider, exposed_in_find: true, open_on_apply: false)
    create(:course_option, site: site, course: course1)
    create(:course_option, site: site, course: course2)
    create(:provider, name: 'Provider with no courses', code: 'FAKE')
  end

  def and_i_click_on_course_choices
    click_link 'Choose your courses'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
  end

  def and_i_choose_a_provider_without_a_course
    select 'Provider with no courses (FAKE)'
    click_button t('continue')
  end

  def then_i_see_that_i_should_apply_to_the_provider_on_ucas
    expect(page).to have_content(t('page_titles.apply_to_provider_on_ucas'))
  end

  def then_i_see_that_i_should_apply_to_the_course_on_ucas
    expect(page).to have_content(t('page_titles.apply_to_course_on_ucas'))
  end

  def when_i_click_on_back
    click_link 'Back'
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
  end

  def and_i_choose_another_course
    choose 'Secondary (X123)'
    click_button t('continue')
  end

  def and_i_should_be_given_the_selected_training_provider_code
    expect(page).to have_content 'FAKE'
  end

  def and_i_should_be_given_the_selected_training_provider_code_and_course_code
    expect(page).to have_content 'Gorse SCITT (1N1)'
    expect(page).to have_content 'Secondary (X123)'
  end
end
