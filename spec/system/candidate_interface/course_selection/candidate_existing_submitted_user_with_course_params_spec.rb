require 'rails_helper'

RSpec.describe 'An existing candidate arriving from Find with a course and provider code' do
  include CourseOptionHelpers
  scenario 'retaining their course selection through the sign up process' do
    given_the_pilot_is_open
    and_i_am_an_existing_candidate_on_apply
    and_my_application_has_been_submitted

    when_i_arrive_at_the_sign_up_page_with_course_params_with_one_site
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_not_have_more_course_choices_added
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_an_existing_candidate_on_apply
    @email = "#{SecureRandom.hex}@example.com"
    @candidate = create(:candidate, email_address: @email)
  end

  def and_my_application_has_been_submitted
    @application_form = create(:completed_application_form, candidate: @candidate)
  end

  def when_i_arrive_at_the_sign_up_page_with_course_params_with_one_site
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course, vacancy_status: 'B')

    visit candidate_interface_sign_up_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def when_i_arrive_at_the_sign_up_page_with_course_params_with_multiple_sites
    visit candidate_interface_sign_up_path providerCode: @course_with_multiple_sites.provider.code, courseCode: @course_with_multiple_sites.code
  end

  def and_i_submit_my_email_address
    perform_enqueued_jobs do
      fill_in t('authentication.sign_up.email_address.label'), with: @email
      check t('authentication.sign_up.accept_terms_checkbox')
      click_on t('authentication.sign_up.button_continue')
    end
  end

  def and_click_on_the_magic_link
    open_email(@email)
    current_email.find_css('a').first.click
  end

  def then_i_should_not_have_more_course_choices_added
    expect(@application_form.reload.application_choices).to be_empty
  end
end
