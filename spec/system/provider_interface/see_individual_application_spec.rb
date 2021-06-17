require 'rails_helper'

RSpec.describe 'A Provider viewing an individual application', with_audited: true do
  include CourseOptionHelpers
  include DfESignInHelpers

  before do
    FeatureFlag.deactivate(:restructured_work_history)
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 3, 1, 12, 0, 0)) do
      example.run
    end
  end

  scenario 'the application data is visible' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_my_organisation_has_received_an_application
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface

    then_i_should_see_the_candidates_degrees
    and_i_should_see_the_candidates_gcses
    and_i_should_not_see_the_safeguarding_declaration_details

    when_i_am_permitted_to_see_safeguarding_information
    and_i_visit_that_application_in_the_provider_interface

    then_i_should_see_the_safeguarding_declaration_section
    and_i_should_see_the_candidates_other_qualifications
    and_i_should_see_the_candidates_work_history
    and_i_should_see_the_candidates_volunteering_history
    and_i_should_see_the_candidates_personal_statement
    and_i_should_see_the_candidates_language_skills
    and_i_should_see_the_candidates_references
    and_i_should_see_the_disability_disclosure
    and_i_should_see_diversity_information_section
    and_i_should_see_a_link_to_download_as_pdf
  end

  def and_i_should_not_see_the_safeguarding_declaration_details
    expect(page).to have_content('Criminal convictions and professional misconduct')
    expect(page).not_to have_content('View information disclosed by the candidate')
  end

  def then_i_should_see_the_safeguarding_declaration_section
    expect(page).to have_content('Criminal convictions and professional misconduct')
    expect(page).to have_content(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare'))
  end

  def when_i_am_permitted_to_see_safeguarding_information
    ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
      .provider_permissions.update_all(view_safeguarding_information: true)

    create(
      :provider_relationship_permissions,
      ratifying_provider: create(:provider),
      training_provider: @application_choice.course.provider,
      training_provider_can_view_safeguarding_information: true,
      setup_at: Time.zone.now,
    )
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
      becoming_a_teacher: 'This is my personal statement',
      subject_knowledge: 'This is my subject knowledge',
      interview_preferences: 'Any date is fine',
      further_information: 'Nothing further to add',
      english_main_language: true,
      other_language_details: 'I also speak Spanish and German',
      disclose_disability: true,
      disability_disclosure: 'I am hard of hearing',
      safeguarding_issues: 'I have something to say...',
      safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      equality_and_diversity: { 'sex' => 'male',
                                'disabilities' => ['Mental health condition'],
                                'ethnic_group' => 'Asian or Asian British',
                                'ethnic_background' => 'Chinese' },
    )

    create_list(:application_qualification, 1, application_form: application_form, level: :degree)
    create(:gcse_qualification, subject: 'maths', application_form: application_form)
    create(:gcse_qualification, subject: 'english', application_form: application_form)
    create_list(:application_qualification, 3, application_form: application_form, level: :other)

    create(:application_work_experience,
           application_form: application_form,
           role: 'Smuggler',
           organisation: 'The Empire',
           details: 'I used to work for The Empire',
           working_pattern: 'Working pattern at the Empire',
           working_with_children: false,
           start_date: 36.months.ago,
           end_date: 30.months.ago,
           commitment: 'part_time')

    create(:application_work_experience,
           application_form: application_form,
           role: 'Bounty Hunter',
           organisation: 'The Empire',
           details: 'I used to work for The Empire',
           working_pattern: 'Working pattern at the Empire',
           working_with_children: false,
           start_date: 24.months.ago,
           end_date: 18.months.ago,
           commitment: 'full_time')

    create(:application_work_history_break,
           application_form: application_form,
           reason: 'Retraining to become a bounty hunter',
           start_date: 30.months.ago,
           end_date: 24.months.ago)

    create(:application_volunteering_experience,
           application_form: application_form,
           role: 'Defence co-ordinator',
           organisation: 'Rebel Alliance',
           details: 'Worked with children to help them survive clone attacks',
           working_with_children: true,
           start_date: 10.months.ago,
           end_date: nil)

    create(:selected_reference,
           application_form: application_form,
           name: 'R2D2',
           email_address: 'r2d2@rebellion.org',
           relationship: 'Astromech droid',
           feedback: 'beep boop beep')

    create(:selected_reference,
           :feedback_provided,
           application_form: application_form,
           name: 'C3PO',
           email_address: 'c3p0@rebellion.org',
           relationship: 'Companion droid',
           feedback: 'The possibility of successfully navigating training is approximately three thousand seven hundred and twenty to one')

    create(:reference,
           :feedback_refused,
           application_form: application_form,
           name: 'BB-8')

    @application_choice = create(:application_choice,
                                 status: :unsubmitted,
                                 course_option: course_option,
                                 reject_by_default_at: 20.days.from_now,
                                 application_form: application_form)

    ApplicationStateChange.new(@application_choice).send_to_provider!
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(@application_choice)
  end

  alias_method(
    :and_i_visit_that_application_in_the_provider_interface,
    :when_i_visit_that_application_in_the_provider_interface,
  )

  def then_i_should_see_the_candidates_degrees
    expect(page).to have_selector('[data-qa="degree-qualification"]', count: 1)
  end

  def and_i_should_see_the_candidates_gcses
    expect(page).to have_selector('[data-qa="gcse-qualification"]', count: 2)
  end

  def and_i_should_see_the_candidates_other_qualifications
    expect(page).to have_selector('[data-qa="qualifications-table-other-qualifications"] tbody tr', count: 3)
  end

  def and_i_should_see_the_candidates_work_history
    within '[data-qa="work-history"]' do
      within 'section:eq(1)' do
        expect(page).to have_content 'Unexplained break (2 years and 1 month)'
        expect(page).to have_content 'February 2015 - March 2017'
      end

      within 'section:eq(2)' do
        expect(page).to have_content 'Smuggler - Part time'
        expect(page).to have_content 'March 2017 - September 2017'
        expect(page).to have_content 'The Empire'
        expect(page).to have_content 'I used to work for'
        expect(page).not_to have_content 'Worked with children'
      end

      within 'section:eq(3)' do
        expect(page).to have_content 'Break (6 months)'
        expect(page).to have_content 'September 2017 - March 2018'
      end

      within 'section:eq(4)' do
        expect(page).to have_content 'Bounty Hunter - Full time'
        expect(page).to have_content 'March 2018 - September 2018'
      end

      within 'section:eq(5)' do
        expect(page).to have_content 'Unexplained break (1 year and 6 months)'
        expect(page).to have_content 'September 2018 - March 2020'
      end
    end
  end

  def and_i_should_see_the_candidates_volunteering_history
    within '[data-qa="volunteering"]' do
      expect(page).to have_content 'Defence co-ordinator'
      expect(page).to have_content 'Rebel Alliance'
      expect(page).to have_content 'survive clone attacks'
      expect(page).to have_content 'Worked with children'
      expect(page).to have_content 'May 2019 - Present'

      # Volunteering is not editable
      expect(page).not_to have_content 'Change'
      expect(page).not_to have_content 'Delete'
    end
  end

  def and_i_should_see_the_candidates_personal_statement
    expect(page).to have_content 'This is my personal statement'
    expect(page).to have_content 'This is my subject knowledge'
    expect(page).to have_content 'Any date is fine'
    expect(page).to have_content 'Nothing further to add'
  end

  def and_i_should_see_the_candidates_language_skills
    within '[data-qa="language-skills"]' do
      expect(page).to have_content 'Yes'
      expect(page).to have_content 'I also speak Spanish and German'
    end
  end

  def and_i_should_see_the_candidates_references
    expect(page).to have_selector('[data-qa="reference"]', count: 2)

    expect(page).to have_content 'R2D2'
    expect(page).to have_content 'r2d2@rebellion.org'
    expect(page).to have_content 'Astromech droid'
    expect(page).to have_content 'beep boop beep'

    expect(page).to have_content 'C3PO'
    expect(page).to have_content 'c3p0@rebellion.org'
    expect(page).to have_content 'Companion droid'
    expect(page).to have_content 'The possibility of successfully'

    expect(page).not_to have_content 'BB-8'
  end

  def and_i_should_see_the_disability_disclosure
    expect(page).to have_content 'I am hard of hearing'
  end

  def and_i_should_see_diversity_information_section
    expect(page).to have_content 'The candidate disclosed information in the optional equality and diversity questionnaire.'
    expect(page).to have_content 'This relates to their sex, ethnicity and disability status. We collect this data to help reduce discrimination on these grounds. (This is not the same as the information we request relating to the candidate’s disability, access and other needs)'
  end

  def and_i_should_see_a_link_to_download_as_pdf
    expect(page).to have_link 'Download application (PDF)'
  end
end
