require 'rails_helper'

RSpec.feature 'Selecting a course not on Apply' do
  include CandidateHelper

  scenario 'Candidate selects a course choice that is not on Apply' do
    given_i_am_signed_in
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_on_add_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_another_provider
    then_i_see_that_i_should_apply_on_ucas

    when_i_click_on_back
    and_i_choose_a_provider
    and_i_choose_another_course
    then_i_see_that_i_should_apply_on_ucas
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
    create(:course_option, site: site, course: course1, vacancy_status: 'B')
    create(:course_option, site: site, course: course2, vacancy_status: 'B')
  end

  def and_i_click_on_course_choices
    click_link 'Course choices'
  end

  def and_i_click_on_add_course
    click_link 'Continue'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def and_i_choose_another_provider
    choose 'Another provider'
    click_button 'Continue'
  end

  def then_i_see_that_i_should_apply_on_ucas
    expect(page).to have_content(t('page_titles.not_eligible_yet'))
  end

  def when_i_click_on_back
    click_link 'Back'
  end

  def and_i_choose_a_provider
    choose 'Gorse SCITT (1N1)'
    click_button 'Continue'
  end

  def and_i_choose_another_course
    choose 'Secondary (X123)'
    click_button 'Continue'
  end
end
