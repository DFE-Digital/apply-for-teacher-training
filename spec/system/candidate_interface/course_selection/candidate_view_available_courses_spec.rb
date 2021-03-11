require 'rails_helper'

RSpec.describe 'A candidate can view all providers and courses on Apply' do
  scenario 'seeing the list of courses grouped by provider and region' do
    given_the_pilot_is_open
    and_there_are_providers_with_courses_on_apply

    when_i_visit_the_available_courses_page
    then_i_should_see_the_available_providers_grouped_by_region
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
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

  def then_i_should_see_the_available_providers_grouped_by_region
    expect(page).to have_content 'South West'
    expect(page).to have_content 'St Ives College'
    expect(page).to have_content 'Mathematics'
    expect(page).to have_content 'Chemistry'
    expect(page).to have_content 'Physics'
  end
end
