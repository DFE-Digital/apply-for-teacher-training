require 'rails_helper'

RSpec.describe 'Marking section as complete or incomplete' do
  include CandidateHelper
  before do
    values_checker = instance_double(EqualityAndDiversity::ValuesChecker)
    allow(EqualityAndDiversity::ValuesChecker).to receive(:new).and_return(values_checker)
    allow(values_checker).to receive(:check_values).and_return true
  end

  [
    'Personal information',
    'Contact information',
    'English GCSE or equivalent',
    'Maths GCSE or equivalent',
    'A levels and other qualifications',
    'Degree',
    'Work history',
    'Unpaid experience',
    'Ask for support if you are disabled',
    'Interview availability',
    'References to be requested if you accept an offer',
    'Declare any safeguarding issues',
    'Equality and diversity questions',
  ].each do |section_name|
    scenario "when marking section '#{section_name}' redirects the user" do
      given_i_have_a_completed_application_form
      when_i_sign_in
      and_i_mark_the_section_as_incomplete(section_name)
      then_i_am_redirected_to_your_details_page
      when_i_mark_the_section_as_complete(section_name)
      and_all_sections_are_complete
      then_i_am_redirected_to_your_applications_page
    end
  end

  scenario 'when not all sections are complete' do
    given_i_have_a_completed_application_form
    when_i_sign_in
    and_i_mark_a_section_as_incomplete
    then_i_see_the_incomplete_text
  end

  scenario 'when all sections are complete' do
    given_i_have_a_completed_application_form
    when_i_sign_in
    and_all_details_have_been_completed
    then_i_do_not_see_the_incomplete_text
  end

  scenario 'completion info text', time: mid_cycle do
    given_i_have_a_completed_application_form
    when_i_sign_in
    then_i_dont_see_the_incomplete_applications_text

    when_i_visit_the_details_page
    then_i_see_the_complete_details_text

    when_i_mark_a_section_as_incomplete
    then_i_dont_see_the_complete_details_text

    when_i_visit_the_applications_page
    then_i_see_the_incomplete_applications_text

    when_i_click_on_your_details
    then_i_am_redirected_to_your_details_page

    when_i_add_the_maximum_number_of_choices
    then_i_dont_see_the_complete_details_text
  end

  def and_i_click_on_your_details
    click_link_or_button 'Your details'
  end

  def then_i_do_not_see_the_incomplete_text
    expect(page).to have_no_text 'Complete these sections so that you can start applying to courses. Your details will be shared with the training provider when you apply.'
  end

  def then_i_see_the_incomplete_text
    expect(page).to have_text('Complete these sections so that you can start applying to courses. Your details will be shared with the training provider when you apply.')
  end

  def given_i_have_a_completed_application_form
    @application_form = create(
      :application_form,
      :completed,
      :with_gcses,
      :with_a_levels,
      :with_bachelor_degree,
      full_work_history: true,
      volunteering_experiences_count: 1,
      candidate: current_candidate,
      submitted_at: nil,
      equality_and_diversity: {
        sex: 'Prefer not to say', ethnic_group: 'Prefer not to say', disabilities: ['Prefer not to say'],
        hesa_sex: '96', hesa_disabilities: ['98'], hesa_ethnicity: '998'
      },
    )
    create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def when_i_sign_in
    login_as(current_candidate)
    visit root_path
  end

  def and_i_mark_a_section_as_incomplete
    mark_section(section: 'Declare any safeguarding issues', complete: false)
  end
  alias_method :when_i_mark_a_section_as_incomplete, :and_i_mark_a_section_as_incomplete

  def then_i_am_redirected_to_your_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def when_i_mark_a_section_as_complete
    mark_section(section: 'Declare any safeguarding issues', complete: true)
  end

  alias_method :and_all_details_have_been_completed, :when_i_mark_a_section_as_complete

  def and_all_sections_are_complete
    completed_application_form = CandidateInterface::CompletedApplicationForm.new(application_form: @application_form)
    expect(completed_application_form).to be_valid
  end

  def then_i_am_redirected_to_your_applications_page
    expect(page).to have_current_path candidate_interface_application_choices_path
  end

  def mark_section(section:, complete:)
    complete_choice = complete.present? ? 'Yes, I have completed this section' : 'No, I’ll come back to it later'
    click_link_or_button 'Your details'
    click_link_or_button section
    choose(complete_choice)
    click_link_or_button t('continue')
  end

  def when_i_visit_the_applications_page
    visit candidate_interface_application_choices_path
  end

  def then_i_see_the_incomplete_applications_text
    expect(page).to have_text('You will not be able to submit applications until you have completed your details.')
  end

  def when_i_click_on_your_details
    click_link_or_button 'your details'
  end

  def then_i_dont_see_the_incomplete_applications_text
    expect(page).to have_no_text('You will not be able to submit applications until you have completed your details.')
  end

  def when_i_visit_the_details_page
    visit candidate_interface_details_path
  end

  def then_i_see_the_complete_details_text
    expect(page).to have_text('You can add your applications.')
    expect(page).to have_text('You have completed your details')
    expect(page).to have_text('You can now start applying to courses.')
  end

  def then_i_dont_see_the_complete_details_text
    expect(page).to have_no_text('You can add your applications.')
    expect(page).to have_no_text('You have completed your details')
    expect(page).to have_no_text('You can now start applying to courses.')
  end

  def when_i_add_the_maximum_number_of_choices
    (ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES - 1).times do
      create(:application_choice, :unsubmitted, application_form: @application_form)
    end
  end

  def and_i_mark_the_section_as_incomplete(section_name)
    mark_section(section: section_name, complete: false)
  end

  def when_i_mark_the_section_as_complete(section_name)
    mark_section(section: section_name, complete: true)
  end
end
