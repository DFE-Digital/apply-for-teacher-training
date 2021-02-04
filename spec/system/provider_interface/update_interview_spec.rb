require 'rails_helper'

RSpec.describe 'A provider user changes interview details' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, email_address: 'provider@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  scenario 'updating existing interview details' do
    FeatureFlag.activate(:interviews)

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_an_interview_has_been_arranged_on_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_view_the_application_interviews_tab
    and_i_change_the_interview_details
    then_i_can_see_interview_was_updated
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    permit_make_decisions!
  end

  def and_an_interview_has_been_arranged_on_an_application
    @provider = Provider.find_by_code('ABC')
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :with_scheduled_interview, course_option: course_option)
    @interview = @application_choice.interviews.first
  end

  def when_i_view_the_application_interviews_tab
    visit provider_interface_application_choice_path(@application_choice)
    click_on 'Interviews'
  end

  def and_i_change_the_interview_details
    click_on 'Change details'

    expect(page).to have_field('Day', with: @interview.date_and_time.day)
    expect(page).to have_field('Month', with: @interview.date_and_time.month)
    expect(page).to have_field('Year', with: @interview.date_and_time.year)
    expect(page).to have_field('Time', with: @interview.date_and_time.strftime('%l:%M%P'))
    expect(page).to have_field('Address or online meeting details', with: @interview.location)
    expect(page).to have_field('Additional details (optional)', with: @interview.additional_details)

    @updated_date_and_time = 1.day.since(@interview.date_and_time).change(hour: 10)

    fill_in 'Day', with: @updated_date_and_time.day.to_s
    fill_in 'Time', with: '10am'
    fill_in 'Address or online meeting details', with: 'Zoom meeting'
    fill_in 'Additional details (optional)', with: 'Business casual'

    click_on 'Continue'
  end

  def then_i_can_see_interview_was_updated
    expect(page).to have_content('Check and send new interview details')
    expect(page).to have_content("Date\n#{@updated_date_and_time.to_s(:govuk_date)}")
    expect(page).to have_content("Time\n#{Time.zone.parse('10am').to_s(:govuk_time)}")
    expect(page).to have_content("Address or online meeting details\nZoom meeting")
    expect(page).to have_content("Additional details\nBusiness casual")

    click_on 'Change', match: :first

    fill_in 'Additional details (optional)', with: 'Business casual, first impressions are important.'

    click_on 'Continue'

    expect(page).to have_content("Additional details\nBusiness casual, first impressions are important")

    click_on 'Send new interview details'

    expect(page).to have_content('Interview changed')

    expect(page).to have_content("Upcoming interviews\n#{@updated_date_and_time.to_s(:govuk_date_and_time)}")
    expect(page).to have_content("Address or online meeting details\nZoom meeting")
    expect(page).to have_content("Additional details\nBusiness casual, first impressions are important")
  end
end
