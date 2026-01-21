require 'rails_helper'

RSpec.describe 'Candidate views their previous applications' do
  include CandidateHelper

  scenario 'carries over application and views previously submitted choices' do
    given_i_am_signed_in_with_one_login
    and_i_have_some_previous_application_forms
    and_i_have_current_application_choices_in_some_states

    when_i_visit_my_applications
    then_i_see_the_previous_applications_link

    when_i_click_the_previous_applications_link
    then_i_see_my_application_choices_listed_from_the_previous_two_years

    when_i_click_on_one_of_my_previous_applications
    then_i_see_the_details_page

    when_i_click_back
    then_i_see_my_application_choices_listed_from_the_previous_two_years
    and_i_do_not_see_any_of_my_current_cycle_applications_listed

    when_i_click_back_to_applications
    then_i_see_my_current_application_choices_page
  end

  scenario 'carries over application and does not see the previously submitted link' do
    given_i_am_signed_in_with_one_login
    when_i_visit_my_applications
    then_i_do_not_see_the_previous_applications_link
  end

private

  def and_i_have_some_previous_application_forms
    @application_form = create(:application_form, :submitted, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
    @application_form_previous_two_years = create(:application_form, recruitment_cycle_year: @application_form.recruitment_cycle_year - 2, submitted_at: 2.years.ago, candidate: @current_candidate)
    @application_form_previous_year = create(:application_form, recruitment_cycle_year: @application_form.recruitment_cycle_year - 1, submitted_at: 1.year.ago, candidate: @current_candidate, previous_application_form_id: @application_form_previous_two_years.id)
    @application_form.update(previous_application_form_id: @application_form_previous_year.id)

    @withdrawn_application_choice_previous_year = create(:application_choice, :withdrawn, application_form: @application_form_previous_year)
    @draft_application_choice_previous_year = create(:application_choice, :unsubmitted, application_form: @application_form_previous_year)
    @declined_application_choice_previous_two_years = create(:application_choice, :declined, application_form: @application_form_previous_two_years)
    @rejected_application_choice_previous_two_years = create(:application_choice, :rejected, application_form: @application_form_previous_two_years)
  end

  def and_i_have_current_application_choices_in_some_states
    %w[offer unsubmitted rejected].each do |state|
      create(:application_choice, state, application_form: @application_form)
    end
  end

  def and_click_continue_to_carry_over_my_application
    click_link_or_button 'Continue'
  end

  def then_i_see_the_previous_applications_link
    expect(page).to have_link('View your previous applications', href: '/candidate/application/choices/previous-applications')
  end

  def then_i_do_not_see_the_previous_applications_link
    expect(page).to have_no_link('View your previous applications', href: '/candidate/application/choices/previous-applications')
  end

  def when_i_click_the_previous_applications_link
    click_link_or_button 'View your previous applications'
  end

  def then_i_see_my_application_choices_listed_from_the_previous_two_years
    expect(page).to have_content("Applications for courses in the #{@application_form.recruitment_cycle_year - 2} to #{@application_form.recruitment_cycle_year - 1} recruitment cycle")

    expect(page).to have_link(@withdrawn_application_choice_previous_year.provider.name, href: "/candidate/application/choices/previous-applications/#{@withdrawn_application_choice_previous_year.id}")
    expect(page).to have_content(@withdrawn_application_choice_previous_year.course.name_and_code)
    expect(page).to have_content(@withdrawn_application_choice_previous_year.course.study_mode.humanize)
    expect(page).to have_content('Application withdrawn')

    expect(page).to have_link(@draft_application_choice_previous_year.provider.name, href: "/candidate/application/choices/previous-applications/#{@draft_application_choice_previous_year.id}")
    expect(page).to have_content(@draft_application_choice_previous_year.course.name_and_code)
    expect(page).to have_content(@draft_application_choice_previous_year.course.study_mode.humanize)
    expect(page).to have_content('Draft')

    expect(page).to have_content("Applications for courses in the #{@application_form.recruitment_cycle_year - 3} to #{@application_form.recruitment_cycle_year - 2} recruitment cycle")

    expect(page).to have_link(@declined_application_choice_previous_two_years.provider.name, href: "/candidate/application/choices/previous-applications/#{@declined_application_choice_previous_two_years.id}")
    expect(page).to have_content(@declined_application_choice_previous_two_years.course.name_and_code)
    expect(page).to have_content(@declined_application_choice_previous_two_years.course.study_mode.humanize)
    expect(page).to have_content('Offer declined')

    expect(page).to have_link(@rejected_application_choice_previous_two_years.provider.name, href: "/candidate/application/choices/previous-applications/#{@rejected_application_choice_previous_two_years.id}")
    expect(page).to have_content(@rejected_application_choice_previous_two_years.course.name_and_code)
    expect(page).to have_content(@rejected_application_choice_previous_two_years.course.study_mode.humanize)
    expect(page).to have_content('Unsuccessful')
  end

  def when_i_click_on_one_of_my_previous_applications
    click_link_or_button @rejected_application_choice_previous_two_years.provider.name.to_s
  end

  def then_i_see_the_details_page
    expect(page).to have_content("Your application to #{@rejected_application_choice_previous_two_years.provider.name}")
    expect(page).to have_content(@rejected_application_choice_previous_two_years.course.name_and_code)
    expect(page).to have_content(@rejected_application_choice_previous_two_years.course.qualifications_to_s)
    expect(page).to have_content(@rejected_application_choice_previous_two_years.course.study_mode.humanize.to_s)
    expect(page).to have_content(@rejected_application_choice_previous_two_years.personal_statement)
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_click_back_to_applications
    click_link_or_button 'Back to your applications'
  end

  def then_i_see_my_current_application_choices_page
    expect(page).to have_content('Your applications')
  end

  def and_i_do_not_see_any_of_my_current_cycle_applications_listed
    expect(page).to have_no_content("Applications for courses in the #{@application_form.recruitment_cycle_year - 1} to #{@application_form.recruitment_cycle_year} recruitment cycle")
    expect(page).to have_no_content(@application_form.application_choices.first.provider.name)
  end
end
