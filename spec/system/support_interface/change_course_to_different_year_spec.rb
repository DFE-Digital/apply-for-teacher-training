require 'rails_helper'

RSpec.describe 'Change course choice to a different year' do
  include DfESignInHelpers

  before do
    given_i_am_a_support_user
    and_there_is_a_submitted_application_in_the_system_with_a_deferred_offer
    and_i_visit_the_support_page
    when_i_click_on_an_application
  end

  scenario 'Support user changes offered course for a submitted application' do
    when_i_click_on_change_offered_course
    then_i_see_the_change_course_page
    and_i_complete_the_form_for_a_course
    and_i_provide_a_valid_zendesk_ticket
    and_i_confirm_changing_the_offer
    and_i_click_change

    then_i_am_redirected_to_the_application_form_page
    and_i_see_new_course_has_been_offered
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_submitted_application_in_the_system_with_a_deferred_offer
    @application_form = create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder')
    @application_choice = create(:application_choice, :offer_deferred, application_form: @application_form)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_link_or_button 'Alice Wunder'
  end

  def when_i_click_on_change_offered_course
    click_link_or_button 'Change course choice'
  end

  def then_i_see_the_change_course_page
    expect(page).to have_current_path support_interface_application_form_change_course_choice_path(
      application_form_id: @application_form.id,
      application_choice_id: @application_choice.id,
    )
  end

  def and_i_complete_the_form_for_a_course
    course = create(:course, :open, provider: @application_choice.provider, recruitment_cycle_year: RecruitmentCycle.previous_year)
    @course_option = create(:course_option, course: course)
    course_code = @course_option.course.code

    fill_in('Provider code', with: @application_choice.provider.code)
    fill_in('Course code', with: course_code)
    fill_in('Site code', with: @course_option.site.code)
    choose('Full time')
    choose(RecruitmentCycle.previous_year)
  end

  def and_i_provide_a_valid_zendesk_ticket
    fill_in('Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/example')
  end

  def and_i_confirm_changing_the_offer
    check 'I have read the guidance'
  end

  def and_i_click_change
    click_link_or_button 'Change'
  end

  def then_i_am_redirected_to_the_application_form_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def and_i_see_new_course_has_been_offered
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
    expect(page).to have_content("2024: #{@course_option.course.name} (#{@course_option.course.code})")
  end
end
