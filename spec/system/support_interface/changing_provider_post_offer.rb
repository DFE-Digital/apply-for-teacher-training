require 'rails_helper'

RSpec.feature 'Changing provider post-offer' do
  include DfESignInHelpers

  scenario 'Old provider tries to view the candidate when offer is made' do
    given_some_suitable_records_with_an_offer(:offered)
    then_the_provider_for_that_offer_can_view_the_application
    when_a_support_user_changes_the_course_of_an_offer_to_one_of_another_provider
    then_the_new_provider_can_view_the_application
    and_the_old_provider_cannot_view_the_application
  end

  scenario 'Old provider tries to view the candidate when offer is accepted' do
    given_some_suitable_records_with_an_offer(:accepted)
    then_the_provider_for_that_offer_can_view_the_application
    when_a_support_user_changes_the_course_of_an_offer_to_one_of_another_provider
    then_the_new_provider_can_view_the_application
    and_the_old_provider_cannot_view_the_application
  end

  def given_some_suitable_records_with_an_offer(status)
    support_user_exists_in_dfe_sign_in
    @application_choice = create(:application_choice, status)
    @original_course_option = @application_choice.current_course_option
    @new_course_option = create(:course_option, :open_on_apply, :full_time)
    support_user_signs_in_using_dfe_sign_in
  end

  def then_the_provider_for_that_offer_can_view_the_application
    provider_can_view_application(provider: @original_course_option.provider)
  end

  def when_a_support_user_changes_the_course_of_an_offer_to_one_of_another_provider
    visit support_interface_application_form_path(@application_choice.application_form)
    expect(page).to have_content(@application_choice.application_form.support_reference)

    if @application_choice.offer?
      click_on 'Change course choice'
      fill_in 'Provider code', with: @new_course_option.provider.code
      fill_in 'Course code', with: @new_course_option.course.code
      choose 'Full time'
      fill_in 'Site code', with: @new_course_option.site.code
      fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
      check 'I have read the guidance'
      click_on 'Change'
    elsif @application_choice.pending_conditions?
      click_on 'Change offered course'
      fill_in 'Course code', with: @new_course_option.course.code
      click_on 'Search'
      choose "#{@new_course_option.course.provider.name_and_code} – #{@new_course_option.course.name_and_code}"
      click_on 'Continue'
      fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
      check 'I have read the guidance'
      click_on 'Continue'
    end
  end

  def then_the_new_provider_can_view_the_application
    provider_can_view_application(provider: @new_course_option.provider)
  end

  def and_the_old_provider_cannot_view_the_application
    provider_can_view_application(provider: @original_course_option.provider, expect: :not_to)
  end

  def provider_can_view_application(provider:, expect: :to)
    user = provider.provider_users.first
    visit support_interface_provider_user_path(user)
    click_on 'Sign in as this provider user'
    click_on 'Visit Manage'
    click_on 'Your account'
    click_on 'Your personal details'
    expect(page).to have_content(user.email_address)

    click_on 'Applications'
    expect(page).public_send(expect, have_content(@application_choice.application_form.full_name))

    visit provider_interface_application_choice_path(@application_choice)
    expect(page).public_send(expect, have_content(@application_choice.application_form.full_name))
  end
end
