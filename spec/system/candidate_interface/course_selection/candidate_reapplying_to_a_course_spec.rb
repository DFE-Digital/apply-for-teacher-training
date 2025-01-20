require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  it 'Candidate selects a course they are reapplying to' do
    given_i_am_signed_in_with_one_login
    and_there_is_one_course_option
    and_i_have_a_rejected_application

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_the_same_provider
    then_i_see_the_course_and_its_description

    and_i_choose_the_same_course
    then_i_am_on_the_application_choice_review_page
  end

  def and_there_is_one_course_option
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, course: @course)
  end

  def then_i_am_on_the_application_choice_review_page
    expect(application_choice).to be_present
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_path(application_choice_id: application_choice.id),
    )
  end

  def and_i_have_a_rejected_application
    create(:application_choice, :rejected, course_option: @course.course_options.first, application_form: current_candidate.current_application)
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

  def and_i_choose_the_same_provider
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
  end

  def then_i_see_the_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description_to_s)
  end

  def and_i_choose_the_same_course
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end
end
