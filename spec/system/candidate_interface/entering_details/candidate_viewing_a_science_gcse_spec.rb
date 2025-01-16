require 'rails_helper'

RSpec.describe 'Candidate viewing Science GCSE' do
  include CandidateHelper

  it 'Candidate views a Science GCSE only when a primary course is chosen' do
    given_i_am_signed_in_with_one_login
    and_i_am_on_your_application_page
    then_i_dont_see_science_gcse

    when_i_complete_your_details
    then_i_dont_see_science_gcse_is_incomplete_below_the_section

    when_i_choose_a_primary_course
    then_i_see_science_gcse_is_incomplete_below_the_section

    when_i_choose_a_secondary_course
    then_i_dont_see_a_science_gcse_validation_error

    and_i_am_on_your_application_page
    then_i_see_science_gcse
    and_i_complete_science_gcse

    when_i_go_to_view_my_application
    then_i_do_not_see_a_science_gcse_validation_error
  end

  def and_i_complete_science_gcse
    click_link_or_button t('sections.science_gcse')
    candidate_explains_a_missing_gcse
  end

  def and_i_am_on_your_application_page
    visit candidate_interface_details_path
  end
  alias_method :when_i_am_on_your_application_page, :and_i_am_on_your_application_page

  def when_i_complete_your_details
    candidate_completes_details_except_science
  end

  def when_i_choose_a_secondary_course
    choose_a_secondary_course
  end

  def then_i_see_science_gcse
    expect(page).to have_content(t('sections.science_gcse'))
  end

  def then_i_see_science_gcse_is_incomplete_below_the_section
    expect(page).to have_content('To apply for a Primary course, you need a GCSE in science at grade 4 (C) or above, or equivalent.')
  end

  def then_i_do_not_see_a_science_gcse_validation_error
    expect(page).to have_no_content('To apply for a Primary course, you need a GCSE in science at grade 4 (C) or above, or equivalent.')
  end

  def then_i_dont_see_science_gcse
    expect(page).to have_no_content(t('sections.science_gcse'))
  end

  def then_i_dont_see_science_gcse_is_incomplete_below_the_section
    expect(page).to have_no_content(t('review_application.science_gcse.incomplete'))
  end

  def choose_a_primary_course
    candidate_fills_in_primary_course_choice
  end

  def choose_a_secondary_course
    visit candidate_interface_application_choices_path
    click_link_or_button t('section_items.add_application')
    candidate_fills_in_secondary_course_choice
  end

  def when_i_go_to_view_my_application
    @application_choice = current_candidate.current_application.application_choices.unsubmitted.first
    page.find_link(nil, href: candidate_interface_course_choices_course_review_path(@application_choice.id)).click
  end

  def then_i_dont_see_a_science_gcse_validation_error
    expect(page).to have_no_content(t('activemodel.errors.models.candidate_interface/application_choice_submission.attributes.application_choice.incomplete_primary_course_details', link_to_science: 'Add your science'))
  end

  def when_i_choose_a_primary_course
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    candidate_fills_in_primary_course_choice_without_science_gcse
  end

  def candidate_fills_in_primary_course_choice_without_science_gcse
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end
end
