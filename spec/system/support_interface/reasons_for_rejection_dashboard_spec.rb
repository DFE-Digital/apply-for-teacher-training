require 'rails_helper'

RSpec.describe 'Reasons for rejection dashboard', time: Time.zone.local(2023, 1, 10) do
  include DfESignInHelpers

  scenario 'View reasons for rejection', :with_audited do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    then_i_can_see_reasons_for_rejection_dashboard_link
    and_i_click_on_the_reasons_for_rejection_dashboard_link_for_the_current_cycle

    then_i_see_reasons_for_rejection_dashboard
    and_i_see_sub_reasons_for_rejection

    when_i_click_on_a_top_level_reason
    then_i_can_see_a_list_of_applications_for_that_reason

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_reasons_for_rejection_dashboard_link_for_the_current_cycle
    and_i_click_on_a_sub_reason
    then_i_can_see_a_list_of_applications_for_that_sub_reason
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    allow(CycleTimetable).to receive(:apply_opens).and_return(60.days.ago)
    @application_choice1 = create(:application_choice, :awaiting_provider_decision)
    @application_choice2 = create(:application_choice, :awaiting_provider_decision)
    @application_choice3 = create(:application_choice, :awaiting_provider_decision)
    @application_choice4 = create(:application_choice, :awaiting_provider_decision)
    @application_choice5 = create(:application_choice, :awaiting_provider_decision)
    @application_choice6 = create(:application_choice, :awaiting_provider_decision)

    reject_application_for_qualifications_and_safeguarding(@application_choice4)
    reject_application_for_visa_sponsorship(@application_choice5)
    reject_application_without_structured_reasons(@application_choice6)

    travel_temporarily_to(40.days.ago) do
      reject_application_for_qualifications_and_safeguarding(@application_choice1)
      reject_application_for_teaching_knowledge_and_communication_and_scheduling(@application_choice2)
      reject_application_for_visa_sponsorship(@application_choice3)
    end
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def then_i_can_see_reasons_for_rejection_dashboard_link
    expect(page).to have_link('2022 to 2023 (starts 2023) - current')
  end

  def and_i_click_on_the_reasons_for_rejection_dashboard_link_for_the_current_cycle
    click_link_or_button '2022 to 2023 (starts 2023) - current'
  end

  def then_i_see_reasons_for_rejection_dashboard
    then_i_see_reasons_for_rejection_title_and_details
    and_i_see_reasons_for_rejection_qualifications
    and_i_see_reasons_for_rejection_cannot_sponsor_visa
  end

  def and_i_see_sub_reasons_for_rejection
    and_i_see_sub_reasons_for_rejection_due_to_qualifications
    and_i_see_sub_reasons_for_rejection_due_to_safeguarding
    and_i_see_sub_reasons_for_rejection_due_to_teaching_knowledge_and_communication
  end

private

  def reject_application_for_qualifications_and_safeguarding(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        selected_reasons: [
          {
            id: 'qualifications',
            label: 'Qualification',
            selected_reasons: [
              {
                id: 'unsuitable_degree',
                label: 'Degree does not meet course requirements',
                details: {
                  id: 'unsuitable_degree_details',
                  text: 'The statement lack detail and depth',
                },
              },
              {
                id: 'no_maths_gcse',
                label: 'No maths GCSE at minimum grade 4 or C, or equivalent',
              },
            ],
          },
          {
            id: 'safeguarding',
            label: 'Safeguarding',
            details: {
              id: 'safeguarding_details',
              text: 'Some safeguarding concern',
            },
          },
        ],
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_for_teaching_knowledge_and_communication_and_scheduling(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        selected_reasons: [
          {
            id: 'teaching_knowledge',
            label: 'Teaching knowledge, ability and interview performance',
            selected_reasons: [
              {
                id: 'teaching_demonstration',
                label: 'Teaching demonstration',
                details: {
                  id: 'teaching_demonstration_details',
                  text: 'A bad demonstration.',
                },
              },
            ],
          },
          {
            id: 'communication_and_scheduling',
            label: 'Communication, interview attendance and scheduling',
            selected_reasons: [
              {
                id: 'did_not_attend_interview',
                label: 'Did not attend interview',
                details: {
                  id: 'did_not_attend_interview_details',
                  text: 'No response to our interview invite via email and telephone calls.',
                },
              },
            ],
          },
        ],
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_for_visa_sponsorship(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        selected_reasons: [
          {
            id: 'visa_sponsorship',
            label: 'Visa sponsorship',
            details: {
              id: 'visa_sponsorship_details',
              text: 'We can not sponsor visa',
            },
          },
        ],
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_without_structured_reasons(application_choice)
    application_choice.update!(
      status: :rejected,
      rejected_at: Time.zone.now,
    )
  end

  def then_i_see_reasons_for_rejection_title_and_details
    expect(page).to have_content('2022 to 2023')
    expect(page).to have_content('(starts 2023) Reasons for rejection')
    expect(page).to have_content('The report does not include most rejections made through the API, as rejecting applications by code was only added in version 1.2 of the API.')
    expect(page).to have_content('The percentages for all the categories will not add up to 100% as providers can choose more than 1 reason for rejecting a candidate.')
  end

  def and_i_see_reasons_for_rejection_course_full
    within '#course-full' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_see_reasons_for_rejection_qualifications
    within '#qualifications' do
      expect(page).to have_content('40% 2 of 5 rejections included this category')
      expect(page).to have_content('50% 1 of 2 rejections in January included this category')
    end
  end

  def and_i_see_reasons_for_rejection_safeguarding_concerns
    within '#safeguarding' do
      expect(page).to have_content('40%')
      expect(page).to have_content('2 of 5 rejections included this category')
      expect(page).to have_content('50%')
      expect(page).to have_content('1 of 2 rejections in December included this category')
    end
  end

  def and_i_see_sub_reasons_for_rejection_due_to_qualifications
    within '#qualifications' do
      expect(page).to have_content('40% 2 of 5 rejections included this category')
      expect(page).to have_content('50% 1 of 2 rejections in January included this category')
      expect(page).to have_content('No maths gcse 20% 1 of 5 50% 1 of 2 0% 0 of 2 0% 0 of 1')
      expect(page).to have_content('Unsuitable degree 20% 1 of 5 50% 1 of 2 0% 0 of 2 0% 0 of 1')
    end
  end

  def and_i_see_sub_reasons_for_rejection_due_to_safeguarding
    within '#safeguarding' do
      expect(page).to have_content('40% 2 of 5 rejections included this category')
      expect(page).to have_content('50% 1 of 2 rejections in January included this category')
    end
  end

  def and_i_see_sub_reasons_for_rejection_due_to_teaching_knowledge_and_communication
    within '#teaching-knowledge' do
      expect(page).to have_content('20% 1 of 5 rejections included this category')
      expect(page).to have_content('0% 0 of 2 rejections in January included this category')
      expect(page).to have_content('January within this category Teaching demonstration 20% 1 of 5 100% 1 of 1 0% 0 of 2 0% 0 of 0')
    end

    within '#communication-and-scheduling' do
      expect(page).to have_content('20% 1 of 5 rejections included this category')
      expect(page).to have_content('0% 0 of 2 rejections in January included this category')
      expect(page).to have_content('Percentage of all rejections in January within this category Did not attend interview 20% 1 of 5 100% 1 of 1 0% 0 of 2 0% 0 of 0')
    end
  end

  def and_i_see_reasons_for_rejection_cannot_sponsor_visa
    within '#visa-sponsorship' do
      expect(page).to have_content('40% 2 of 5 rejections included this category')
      expect(page).to have_content('50% 1 of 2 rejections in January included this category')
    end
  end

  def when_i_click_on_a_top_level_reason
    click_link_or_button 'Qualifications'
  end

  def then_i_can_see_a_list_of_applications_for_that_reason
    expect(page).to have_current_path(
      support_interface_reasons_for_rejection_application_choices_path(
        structured_rejection_reasons: { id: 'qualifications' },
        recruitment_cycle_year: RecruitmentCycle.current_year,
      ),
    )
    expect(page).to have_css('h1', text: 'Qualifications')
    [
      @application_choice1,
      @application_choice4,
    ].each { |application_choice| expect(page).to have_link("##{application_choice.id}") }
    [
      @application_choice2,
      @application_choice3,
      @application_choice5,
      @application_choice6,
    ].each { |application_choice| expect(page).to have_no_link("##{application_choice.id}") }

    within "#application-choice-section-#{@application_choice1.id}" do
      expect(page.text).to eq("Application choice ##{@application_choice1.id}\nQualifications\nThe statement lack detail and depthNo maths GCSE at minimum grade 4 or C, or equivalent\nSafeguarding\nSome safeguarding concern")
    end
    within "#application-choice-section-#{@application_choice4.id}" do
      expect(page.text).to eq("Application choice ##{@application_choice4.id}\nQualifications\nThe statement lack detail and depthNo maths GCSE at minimum grade 4 or C, or equivalent\nSafeguarding\nSome safeguarding concern")
    end
  end

  def and_i_click_on_a_sub_reason
    click_link_or_button 'Teaching demonstration'
  end

  def then_i_can_see_a_list_of_applications_for_that_sub_reason
    expect(page).to have_current_path(
      support_interface_reasons_for_rejection_application_choices_path(
        structured_rejection_reasons: { teaching_knowledge: 'teaching_demonstration' },
        recruitment_cycle_year: RecruitmentCycle.current_year,
      ),
    )

    expect(page).to have_css('h1', text: 'Teaching Demonstration')

    [
      @application_choice1,
      @application_choice3,
      @application_choice4,
      @application_choice5,
      @application_choice6,
    ].each { |application_choice| expect(page).to have_no_link("##{application_choice.id}") }
    expect(page).to have_link("##{@application_choice2.id}")

    within "#application-choice-section-#{@application_choice2.id}" do
      expect(page.text).to eq("Application choice ##{@application_choice2.id}\nTeaching Knowledge\nA bad demonstration.\nCommunication And Scheduling\nNo response to our interview invite via email and telephone calls.")
    end
  end
end
