require 'rails_helper'

RSpec.feature 'See providers' do
  include DfESignInHelpers
  include FindAPIHelper

  scenario 'User visits providers page' do
    given_i_am_a_support_user
    and_there_are_providers_in_the_system

    when_i_visit_the_providers_page
    and_i_should_see_the_list_of_providers
    and_i_should_see_providers_course_count
    and_i_should_see_providers_sites_count
    and_i_should_see_providers_dsa_signed_date

    and_when_i_click_the_other_providers_tab
    and_i_should_see_the_list_of_other_providers
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_providers_in_the_system
    @provider = create(:provider, sync_courses: true, name: 'ABC')
    @provider_with_courses = create(:provider, courses: [create(:course)], sync_courses: true, name: 'BCD')
    @provider_with_sites = create(:provider, sites: [create(:site)], sync_courses: true, name: 'CDE')
    @provider_with_signed_agreement = create(:provider, :with_signed_agreement, sync_courses: true, name: 'DEF')
    @other_provider = create(:provider, name: 'XYZ')
  end

  def when_i_visit_the_providers_page
    visit support_interface_providers_path
  end

  def and_i_should_see_the_list_of_providers
    expect(page).to have_content(@provider.name)
    expect(page).to have_content(@provider_with_courses.name)
    expect(page).to have_content(@provider_with_sites.name)
    expect(page).to have_content(@provider_with_signed_agreement.name)
  end

  def and_i_should_see_providers_course_count
    @first_provider_cells = find('table').all('tr')[1].all('td')
    @second_provider_cells = find('table').all('tr')[2].all('td')
    @third_provider_cells = find('table').all('tr')[3].all('td')
    @fourth_provider_cells = find('table').all('tr')[4].all('td')

    expect(@first_provider_cells[1].text).to eq('0 courses 0 on DfE Apply')
    expect(@second_provider_cells[1].text).to eq('1 course 0 on DfE Apply')
    expect(@third_provider_cells[1].text).to eq('0 courses 0 on DfE Apply')
    expect(@fourth_provider_cells[1].text).to eq('0 courses 0 on DfE Apply')
  end

  def and_i_should_see_providers_sites_count
    expect(@first_provider_cells[2].text).to eq('0')
    expect(@second_provider_cells[2].text).to eq('0')
    expect(@third_provider_cells[2].text).to eq('1')
    expect(@fourth_provider_cells[2].text).to eq('0')
  end

  def and_i_should_see_providers_dsa_signed_date
    expect(@first_provider_cells[3].text).to eq('Not accepted yet')
    expect(@second_provider_cells[3].text).to eq('Not accepted yet')
    expect(@third_provider_cells[3].text).to eq('Not accepted yet')
    expect(@fourth_provider_cells[3].text).to eq(Time.zone.today.to_s(:govuk_date))
  end

  def and_when_i_click_the_other_providers_tab
    within('.govuk-tabs__list') { click_link 'Other providers' }
  end

  def and_i_should_see_the_list_of_other_providers
    expect(page).to have_content(@other_provider.name)
  end
end
