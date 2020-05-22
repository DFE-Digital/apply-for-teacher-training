require 'rails_helper'

RSpec.describe 'candidate fills in application' do
  include CandidateHelper

  scenario 'with mark_every_section_complete flag on it updates the relevant section completed booleans' do
    given_i_am_signed_in
    and_i_have_completed_my_application
    then_the_section_completed_booleans_for_each_section_are_set_to_true
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_have_completed_my_application
    candidate_completes_application_form
  end

  def then_the_section_completed_booleans_for_each_section_are_set_to_true
    application_form = ApplicationForm.first
    expect(application_form.personal_details_completed).to be_truthy
    expect(application_form.contact_details_completed).to be_truthy
    expect(application_form.maths_gcse_completed).to be_truthy
    expect(application_form.english_gcse_completed).to be_truthy
    expect(application_form.science_gcse_completed).to be_truthy
    expect(application_form.training_with_a_disability_completed).to be_truthy
    expect(application_form.safeguarding_issues_completed).to be_truthy
    expect(application_form.becoming_a_teacher_completed).to be_truthy
    expect(application_form.subject_knowledge_completed).to be_truthy
    expect(application_form.interview_preferences_completed).to be_truthy
    expect(application_form.references_completed).to be_truthy
  end
end
