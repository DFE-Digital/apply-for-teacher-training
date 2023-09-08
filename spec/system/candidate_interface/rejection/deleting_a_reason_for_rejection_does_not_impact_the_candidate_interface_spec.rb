require 'rails_helper'

RSpec.feature 'Candidate can see their structured reasons for rejection when reviewing their application', continuous_applications: false, time: CycleTimetableHelper.mid_cycle do
  scenario 'despite us removing one of them as a valid reason for rejection' do
    given_i_am_signed_in

    and_i_have_an_apply1_application_with_rejections

    when_i_visit_my_application_complete_page
    then_i_can_see_my_rejection_reasons

    when_i_apply_again
    then_i_can_see_rejection_reasons_from_the_earlier_application
    and_i_should_see_unsuccessful_status
    and_i_should_not_see_a_link_to_the_course_on_find
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_apply1_application_with_rejections
    travel_temporarily_to(mid_cycle(CycleTimetable.previous_year)) do
      @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
      @application_choice = create(:application_choice, :with_structured_rejection_reasons, application_form: @application_form).tap do |ac|
        ac.structured_rejection_reasons['selected_reasons'] << {
          id: 'references', label: 'References',
          details: {
            id: 'references_details',
            text: 'We do not accept references from close family members, such as your mum.',
          }
        }
        ac.save!
      end
    end
  end

  def when_i_visit_my_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def then_i_can_see_my_rejection_reasons
    expect(page).to have_content('Quality of writing')
    expect(page).to have_content('such as your mum')
  end

  def when_i_apply_again
    click_on 'Apply again'
  end

  def then_i_can_see_rejection_reasons_from_the_earlier_application
    expect(page).to have_content('Quality of writing')
    expect(page).to have_content('such as your mum')
  end

  def and_i_should_see_unsuccessful_status
    expect(page).to have_content('Unsuccessful')
  end

  def and_i_should_not_see_a_link_to_the_course_on_find
    course_name = @application_choice.current_course.name_and_code
    expect(page).to have_content(course_name)
    expect(page).not_to have_link(course_name)
  end
end
