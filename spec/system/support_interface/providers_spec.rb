require 'rails_helper'

RSpec.feature 'See providers' do
  include DfESignInHelpers
  include FindAPIHelper

  scenario 'User visits providers page' do
    given_i_am_a_support_user
    and_providers_are_configured_to_be_synced
    when_i_visit_the_providers_page
    and_i_click_the_sync_button
    then_requests_to_find_should_be_made
    and_i_should_see_the_updated_list_of_providers

    when_i_click_on_a_provider
    then_i_see_the_providers_courses_and_sites

    when_i_click_on_a_course
    then_i_see_the_course_information

    when_i_choose_to_open_the_course_on_apply
    then_it_should_be_open_on_apply

    when_i_visit_the_providers_page
    when_i_click_on_a_provider
    then_i_see_the_updated_providers_courses_and_sites

    when_i_visit_the_providers_page
    when_i_click_on_a_different_provider
    and_i_choose_to_open_all_courses
    then_all_courses_should_be_open_on_apply
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_providers_page
    visit support_interface_providers_path
  end

  def and_providers_are_configured_to_be_synced
    allow(Rails.application.config).to receive(:providers_to_sync)
      .and_return(codes: %w[ABC DEF GHI])
  end

  def then_i_should_see_the_providers
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).not_to have_content('Gorse SCITT')
    expect(page).not_to have_content('Somerset SCITT Consortium')
  end

  def and_i_click_the_sync_button
    @request1 = stub_find_api_provider_200(
      provider_code: 'ABC',
      provider_name: 'Royal Academy of Dance',
      course_code: 'ABC-1',
      site_code: 'X',
    )

    @request2 = stub_find_api_provider_200(
      provider_code: 'DEF',
      provider_name: 'Gorse SCITT',
      course_code: 'DEF-1',
      site_code: 'Y',
    )

    @request3 = stub_find_api_provider_200(
      provider_code: 'GHI',
      provider_name: 'Somerset SCITT Consortium',
      course_code: 'GHI-1',
      site_code: 'C',
    )

    Sidekiq::Testing.inline! do
      click_button 'Sync Providers from Find'
    end
  end

  def then_requests_to_find_should_be_made
    expect(@request1).to have_been_made
    expect(@request2).to have_been_made
    expect(@request3).to have_been_made
  end

  def and_i_should_see_the_updated_list_of_providers
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).to have_content('Gorse SCITT')
    expect(page).to have_content('Somerset SCITT Consortium')
  end

  def when_i_click_on_a_provider
    click_link 'Royal Academy of Dance'
  end

  def then_i_see_the_providers_courses_and_sites
    expect(page).to have_content 'ABC-1'
    expect(page).to have_content '1 course (0 on DfE Apply)'
  end

  def when_i_click_on_a_course
    click_link 'ABC-1'
  end

  def then_i_see_the_course_information
    expect(page).to have_title 'Primary (ABC-1)'
  end

  def when_i_choose_to_open_the_course_on_apply
    expect(page).to have_content 'Open on Apply No'
    choose 'Yes, this course is available on Apply and UCAS'
    click_button 'Save'
  end

  def then_it_should_be_open_on_apply
    expect(page).to have_content 'Open on Apply Yes'
  end

  def then_i_see_the_updated_providers_courses_and_sites
    expect(page).to have_content 'ABC-1'
    expect(page).to have_content '1 course (1 on DfE Apply)'
  end

  def when_i_click_on_a_different_provider
    click_link 'Gorse SCITT'
  end

  def and_i_choose_to_open_all_courses
    click_button 'Open 1 course'
  end

  def then_all_courses_should_be_open_on_apply
    expect(page).to have_content '1 course (1 on DfE Apply)'
  end
end
