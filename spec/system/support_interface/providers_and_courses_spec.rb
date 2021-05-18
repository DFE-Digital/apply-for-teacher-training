require 'rails_helper'

RSpec.feature 'Providers and courses' do
  include DfESignInHelpers
  include TeacherTrainingPublicAPIHelper

  scenario 'User syncs provider and browses providers' do
    given_i_am_a_support_user
    and_providers_are_configured_to_be_synced
    and_the_last_sync_was_two_hours_ago
    when_i_visit_the_tasks_page
    and_i_click_the_sync_button

    when_i_visit_the_providers_page
    and_i_should_see_the_updated_list_of_providers
    when_i_search_a_provider
    then_i_see_the_search_results

    when_i_click_on_a_provider
    and_i_click_on_sites
    then_i_see_the_provider_sites

    when_i_click_on_users
    then_i_see_the_provider_users

    when_i_click_on_applications
    then_i_see_the_provider_applications

    and_i_click_on_courses
    then_i_see_the_provider_courses

    and_i_click_on_ratified_courses
    then_i_see_the_provider_ratified_courses

    when_i_click_on_a_course_with_applications
    then_i_see_the_course_information

    when_i_visit_course_applications
    then_i_see_applications_to_this_course

    when_i_visit_course_vacancies
    then_i_see_courses_with_vacancies

    when_i_visit_course
    when_i_choose_to_open_the_course_on_apply
    then_it_should_be_open_on_apply

    when_i_visit_the_providers_page
    and_i_click_on_an_accredited_body
    and_i_click_on_courses
    no_courses_should_be_open_on_apply
    and_i_click_on_ratified_courses
    no_ratified_courses_should_be_open_on_apply
    and_i_click_on_courses
    and_i_choose_to_open_all_courses
    then_all_courses_should_be_open_on_apply
    and_when_i_click_on_ratified_courses
    then_all_ratified_courses_should_be_open_on_apply
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_tasks_page
    visit support_interface_tasks_path
  end

  def and_providers_are_configured_to_be_synced
    provider = create :provider, :with_signed_agreement, code: 'ABC', name: 'Royal Academy of Dance', sync_courses: true
    create(:provider_user, email_address: 'harry@example.com', providers: [provider])

    course_option = create(:course_option, course: create(:course, provider: provider))
    create(:application_choice, application_form: create(:application_form, support_reference: 'XYZ123'), course_option: course_option)

    create :provider, :with_signed_agreement, code: 'DEF', name: 'Gorse SCITT', sync_courses: true
    create :provider, :with_signed_agreement, code: 'DOF', name: 'An Unsynced Provider', sync_courses: false
    somerset_scitt = create :provider, :with_signed_agreement, code: 'GHI', name: 'Somerset SCITT Consortium', sync_courses: true

    create(:course_option, course: create(:course, accredited_provider: provider))

    create(:course_option, course: create(:course, exposed_in_find: true, accredited_provider: somerset_scitt))
    create(:course_option, course: create(:course, exposed_in_find: true, provider: somerset_scitt))
  end

  def and_the_last_sync_was_two_hours_ago
    @updated_since = Time.zone.now - 2.hours
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def then_i_should_see_the_providers
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).not_to have_content('Gorse SCITT')
    expect(page).not_to have_content('Somerset SCITT Consortium')
  end

  def and_i_click_the_sync_button
    sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
    allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)

    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'ABC',
          name: 'Royal Academy of Dance',
        },
        {
          code: 'DEF',
          name: 'Gorse SCITT',
        },
        {
          code: 'GHI',
          name: 'Somerset SCITT Consortium',
        },
        {
          code: 'XYZ',
          name: 'University of Chester',
        },
      ],
      filter_option: { 'filter[updated_since]' => @updated_since },
    )

    stub_teacher_training_api_provider(
      provider_code: 'XYZ',
      specified_attributes: {
        code: 'XYZ',
      },
    )

    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               course_attributes: [{ accredited_body_code: 'XYZ', qualifications: %w[qts pgce], name: 'Primary' }],
                                               site_code: 'X',
                                               site_attributes: [{ name: 'Main site' }],
                                               filter_option: { 'filter[updated_since]' => @updated_since })

    stub_teacher_training_api_course_with_site(provider_code: 'DEF',
                                               course_code: 'DEF1',
                                               course_attributes: [{ accredited_body_code: 'ABC' }],
                                               filter_option: { 'filter[updated_since]' => @updated_since },
                                               site_code: 'Y')

    stub_teacher_training_api_course_with_site(provider_code: 'GHI',
                                               course_code: 'GHI1',
                                               course_attributes: [{ accredited_body_code: 'GHI' }],
                                               filter_option: { 'filter[updated_since]' => @updated_since },
                                               site_code: 'C')

    Sidekiq::Testing.inline! do
      click_button 'Sync providers'
    end
  end

  def when_i_visit_the_providers_page
    visit support_interface_providers_path
  end

  def and_i_should_see_the_updated_list_of_providers
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).to have_content('Gorse SCITT')
    expect(page).to have_content('Somerset SCITT Consortium')
  end

  def when_i_search_a_provider
    fill_in :q, with: 'Royal'
    click_on 'Apply filters'
  end

  def then_i_see_the_search_results
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).not_to have_content('Gorse SCITT')
    expect(page).not_to have_content('Somerset SCITT Consortium')
  end

  def when_i_click_on_a_provider
    click_link 'Royal Academy of Dance'
  end

  def and_i_click_on_sites
    click_link 'Sites'
  end

  def and_i_click_on_courses
    click_link 'Courses'
  end

  def and_i_click_on_ratified_courses
    click_link 'Ratified courses'
  end

  def when_i_click_on_users
    within 'main' do
      click_link 'Users'
    end
  end

  def then_i_see_the_provider_users
    expect(page).to have_content 'harry@example.com'
  end

  def when_i_click_on_applications
    click_link 'Applications'
  end

  def then_i_see_the_provider_applications
    expect(page).to have_content 'XYZ123'
  end

  def then_i_see_the_provider_courses
    expect(page).to have_content '2 courses (0 on DfE Apply)'
  end

  def then_i_see_the_provider_ratified_courses
    expect(page).to have_content 'ratifies 2 courses (0 on DfE Apply)'
  end

  def then_i_see_the_provider_sites
    expect(page).to have_content 'Main site'
  end

  def when_i_click_on_a_course_with_applications
    course = Course.find_by(code: 'ABC1')
    create(:application_choice, course_option: course.course_options.first)
    create(:application_choice, course_option: course.course_options.first)
    click_link 'Courses'
    click_link 'ABC1'
  end

  def then_i_see_the_course_information
    expect(page).to have_title 'Primary (ABC1)'
    expect(page).to have_content 'Open on UCAS only'
  end

  def when_i_visit_course_applications
    course = Course.find_by(code: 'ABC1')
    visit support_interface_course_applications_path(course)
  end

  def then_i_see_applications_to_this_course
    expect(page).to have_title 'Primary (ABC1)'
    expect(page.all('.app-application-card').size).to eq(2)
  end

  def when_i_visit_course_vacancies
    course = Course.find_by(code: 'ABC1')
    visit support_interface_course_vacancies_path(course)
  end

  def then_i_see_courses_with_vacancies
    expect(page).to have_title 'Primary (ABC1)'
    expect(page).to have_content 'Primary (ABC1) - Full time at Main site Vacancies'
  end

  def when_i_visit_course
    course = Course.find_by(code: 'ABC1')
    visit support_interface_course_path(course)
  end

  def when_i_choose_to_open_the_course_on_apply
    expect(page).to have_content 'Where can candidates apply for this course?'
    choose 'Apply and UCAS'
    click_button 'Update'
  end

  def then_it_should_be_open_on_apply
    expect(page).to have_content 'Open on Apply & UCAS'
  end

  def then_i_see_the_updated_providers_courses_and_sites
    expect(page).to have_content 'ABC1'
    expect(page).to have_content 'Vacancies'
    expect(page).to have_content '2 courses (1 on DfE Apply)'
    expect(page).to have_content 'Accredited body'
    expect(page).to have_content 'University of Chester'
  end

  def and_i_choose_to_open_all_courses
    click_button 'Open all courses for the 2021 cycle'
  end

  def then_all_courses_should_be_open_on_apply
    expect(page).to have_content '2 courses (2 on DfE Apply)'
  end

  def and_i_click_on_an_accredited_body
    click_link 'Somerset SCITT'
  end

  def and_when_i_click_on_ratified_courses
    click_link 'Ratified courses'
  end

  def then_all_ratified_courses_should_be_open_on_apply
    expect(page).to have_content 'ratifies 1 course (1 on DfE Apply)'
  end

  def no_courses_should_be_open_on_apply
    expect(page).to have_content '2 courses (0 on DfE Apply)'
  end

  def no_ratified_courses_should_be_open_on_apply
    expect(page).to have_content 'ratifies 1 course (0 on DfE Apply)'
  end
end
