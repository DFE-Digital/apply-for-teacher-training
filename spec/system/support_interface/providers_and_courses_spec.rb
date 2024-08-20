require 'rails_helper'

RSpec.describe 'Providers and courses' do
  include DfESignInHelpers
  include TeacherTrainingPublicAPIHelper

  scenario 'User fetches course CSV info' do
    given_i_am_a_support_user
    and_providers_are_configured
    and_i_visit_a_providers_page
    and_i_click_on_courses
    and_i_click_on_the_csv_button
    then_i_get_a_csv_with_all_the_courses
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_i_visit_the_tasks_page
    visit support_interface_tasks_path
  end

  def and_providers_are_configured
    provider = create(:provider, code: 'ABC', name: 'Royal Academy of Dance')
    create(:provider_user, email_address: 'harry@example.com', providers: [provider])

    course_option = create(:course_option, course: create(:course, provider: provider))
    create(:application_choice, application_form: create(:application_form, support_reference: 'XYZ123'), course_option: course_option)

    create(:provider, code: 'DEF', name: 'Gorse SCITT')
    create(:provider, code: 'DOF', name: 'An Unsynced Provider')
    @somerset_scitt = create(:provider, code: 'GHI', name: 'Somerset SCITT Consortium')

    course_option_with_accredited_provider = create(:course_option, course: create(:course, accredited_provider: provider))
    create(:application_choice, application_form: create(:application_form, support_reference: 'TUV123'), course_option: course_option_with_accredited_provider)

    create(:course_option, course: create(:course, exposed_in_find: true, accredited_provider: @somerset_scitt))
    create(:course_option, course: create(:course, exposed_in_find: true, provider: @somerset_scitt))
  end

  def and_i_visit_a_providers_page
    visit support_interface_provider_path(@somerset_scitt)
  end

  def and_i_click_on_courses
    click_link_or_button 'Courses'
  end

  def and_i_click_on_the_csv_button
    click_link_or_button 'courses as CSV'
  end

  def then_i_get_a_csv_with_all_the_courses
    rows = CSV.parse(page.html, headers: :first_row).map(&:to_h)
    expect(rows).to be_present
    rows.each do |r|
      bodies = [r['accredited_provider_code'], r['provider_code']]
      expect(bodies).to include('GHI')
    end
  end
end
