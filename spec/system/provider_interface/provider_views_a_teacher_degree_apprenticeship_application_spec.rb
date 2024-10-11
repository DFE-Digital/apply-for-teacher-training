require 'rails_helper'

RSpec.describe 'A Provider user views a teacher degree apprenticeship application' do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }

  scenario 'does not see degrees when application is teacher degree apprenticeship without degrees' do
    given_i_am_a_provider_user
    and_i_sign_in_to_the_provider_interface
    and_i_have_submitted_applications

    when_i_visit_the_provider_interface
    and_i_visit_a_teacher_degree_apprenticeship_application

    then_i_see_a_message_on_the_degree_section
    and_i_do_not_see_the_degrees_of_the_candidate
  end

  scenario 'does not see degrees when application is teacher degree apprenticeship with degrees' do
    given_i_am_a_provider_user
    and_i_sign_in_to_the_provider_interface
    and_i_have_submitted_applications
    and_the_application_has_degrees

    when_i_visit_the_provider_interface
    and_i_visit_a_teacher_degree_apprenticeship_application

    then_i_see_a_message_on_the_degree_section
    and_i_do_not_see_the_degrees_of_the_candidate
  end

  scenario 'does see the degrees section when the application is postgraduate' do
    given_i_am_a_provider_user
    and_i_sign_in_to_the_provider_interface
    and_i_have_submitted_applications

    when_i_visit_the_provider_interface
    and_i_visit_a_postgraduate_application

    then_i_dont_see_a_message_on_the_degree_section
    and_i_see_the_degrees_of_the_candidate
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_have_submitted_applications
    @teacher_degree_apprenticeship_application_form = create(:application_form)
    @postgraduate_application_form = create(:application_form, :with_bachelor_degree)
    teacher_degree_apprenticeship_course = create(:course, :teacher_degree_apprenticeship, :open, provider:)
    postgraduate_course = create(:course, :open, provider:)

    @teacher_degree_apprenticeship_application = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: create(:course_option, course: teacher_degree_apprenticeship_course),
      application_form: @teacher_degree_apprenticeship_application_form,
    )

    @postgraduate_application = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: create(:course_option, course: postgraduate_course),
      application_form: @postgraduate_application_form,
    )
  end

  def and_the_application_has_degrees
    create(:degree_qualification, :bachelor, application_form: @teacher_degree_apprenticeship_application_form)
  end

  def and_i_visit_a_teacher_degree_apprenticeship_application
    visit provider_interface_application_choice_path(@teacher_degree_apprenticeship_application)
  end

  def and_i_visit_a_postgraduate_application
    visit provider_interface_application_choice_path(@postgraduate_application)
  end

  def then_i_see_a_message_on_the_degree_section
    expect(page).to have_content('A degree is not required for a teacher degree apprenticeship (TDA)')
  end

  def then_i_dont_see_a_message_on_the_degree_section
    expect(page).to have_no_content('A degree is not required for a teacher degree apprenticeship (TDA)')
  end

  def and_i_see_the_degrees_of_the_candidate
    expect(@postgraduate_application_form.application_qualifications.degrees.count).to be 1

    @postgraduate_application_form.application_qualifications.degrees.each do |degree|
      expect(page).to have_content(degree.subject)
      expect(page).to have_content(degree.institution_name)
    end
  end

  def and_i_do_not_see_the_degrees_of_the_candidate
    @teacher_degree_apprenticeship_application_form.application_qualifications.degrees.each do |degree|
      expect(page).to have_no_content(degree.subject)
      expect(page).to have_no_content(degree.institution_name)
    end
  end
end
