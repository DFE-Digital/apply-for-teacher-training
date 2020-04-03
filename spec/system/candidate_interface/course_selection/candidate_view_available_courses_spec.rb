require 'rails_helper'

RSpec.describe 'A candidate can view all providers and courses on Apply' do
  include FindAPIHelper

  scenario 'seeing the list of courses grouped by provider and region' do
    given_the_pilot_is_open
    and_the_create_account_or_sign_in_page_feature_flag_is_active
    and_there_are_providers_with_courses_on_apply

    when_i_visit_the_available_courses_page
    then_i_should_see_the_available_courses_grouped_by_providers

    when_group_by_region_feature_is_active

    when_i_visit_the_available_courses_page
    then_i_should_see_the_available_providers_grouped_by_region
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_group_by_region_feature_is_active
    FeatureFlag.activate('group_providers_by_region')
  end

  def and_the_create_account_or_sign_in_page_feature_flag_is_active
    FeatureFlag.activate('create_account_or_sign_in_page')
  end

  def and_there_are_providers_with_courses_on_apply
    @st_ives = create :provider, code: 'SIC', name: 'St Ives College', region_code: :south_west, sync_courses: true
    create :course, :open_on_apply, name: 'Mathematics', provider: @st_ives
    create :course, :open_on_apply, name: 'Chemistry', provider: @st_ives
    create :course, :open_on_apply, name: 'Physics', provider: @st_ives
  end

  def when_i_visit_the_available_courses_page
    visit candidate_interface_providers_path
  end

  def then_i_should_see_the_available_courses_grouped_by_providers
    expect(page).not_to have_content 'South West'
    expect(page).to have_content 'St Ives College'
    expect(page).to have_content 'Mathematics'
    expect(page).to have_content 'Chemistry'
    expect(page).to have_content 'Physics'
  end

  def then_i_should_see_the_available_providers_grouped_by_region
    expect(page).to have_content 'South West'
    expect(page).to have_content 'St Ives College'
    expect(page).to have_content 'Mathematics'
    expect(page).to have_content 'Chemistry'
    expect(page).to have_content 'Physics'
  end
end
