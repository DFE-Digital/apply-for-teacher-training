require 'rails_helper'

RSpec.describe 'Provider changes a course on pending conditions' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Change training provider' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_the_provider_user_can_offer_multiple_provider_courses
    and_i_sign_in_to_the_provider_interface

    when_i_click(@application_form.full_name)
    and_i_click('Offer')
    and_i_click('Change training provider')

    when_i_chose_another_provider
    and_i_click('Continue')

    when_i_choose_part_time
    and_i_click('Continue')

    then_i_review_the_selections(
      provider: @another_provider.name,
      course: @another_provider_course.name_and_code,
      study_mode: 'Part time',
      site_postcode: @another_provider_course.sites.first.postcode,
    )
    and_i_click('Update course')
    then_the_application_choice_is_updated(
      provider: @another_provider,
      course: @another_provider_course,
      study_mode: 'part_time',
      site: @another_provider_course.sites.first,
    )
  end

  scenario 'Change course' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_the_provider_user_can_offer_multiple_provider_courses
    and_i_sign_in_to_the_provider_interface

    when_i_click(@application_form.full_name)
    and_i_click('Offer')
    and_i_click('Change course')

    when_i_chose_another_course
    and_i_click('Continue')

    when_i_choose_part_time
    and_i_click('Continue')

    then_i_review_the_selections(
      provider: @source_provider.name,
      course: @source_provider_course.name_and_code,
      study_mode: 'Part time',
      site_postcode: @source_provider_course.sites.first.postcode,
    )
    and_i_click('Update course')
    then_the_application_choice_is_updated(
      provider: @source_provider,
      course: @source_provider_course,
      study_mode: 'part_time',
      site: @source_provider_course.sites.first,
    )
  end

  scenario 'Change study_mode' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_the_provider_user_can_offer_multiple_provider_courses
    and_i_sign_in_to_the_provider_interface

    when_i_click(@application_form.full_name)
    and_i_click('Offer')
    and_i_click('Change if full time or part time')

    when_i_choose_part_time
    and_i_click('Continue')

    then_i_review_the_selections(
      provider: @source_provider.name,
      course: @course.name_and_code,
      study_mode: 'Part time',
      site_postcode: @part_time_option.site.postcode,
    )
    and_i_click('Update course')
    then_the_application_choice_is_updated(
      provider: @source_provider,
      course: @course,
      study_mode: 'part_time',
      site: @part_time_option.site,
    )
  end

  scenario 'Change site' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_the_provider_user_can_offer_multiple_provider_courses
    and_i_sign_in_to_the_provider_interface

    when_i_click(@application_form.full_name)
    and_i_click('Offer')
    and_i_click('Change location')

    when_i_choose_a_different_site
    and_i_click('Continue')

    then_i_review_the_selections(
      provider: @source_provider.name,
      course: @course.name_and_code,
      study_mode: 'Full time',
      site_postcode: @different_site_option.site.postcode,
    )
    and_i_click('Update course')
    then_the_application_choice_is_updated(
      provider: @source_provider,
      course: @course,
      study_mode: 'full_time',
      site: @different_site_option.site,
    )
  end

  def given_i_am_a_provider_user
    @provider_user = create(
      :provider_user,
      :with_dfe_sign_in,
      :with_make_decisions,
      :with_two_providers,
      :with_set_up_interviews,
    )
    user_exists_in_dfe_sign_in(email_address: @provider_user.email_address)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def and_the_provider_user_can_offer_multiple_provider_courses
    @another_provider = create(:provider)

    @source_provider = @provider_user.providers.first
    @ratifying_provider = create(:provider)

    @course = build(
      :course,
      study_mode: :full_time_or_part_time,
      provider: @source_provider,
      accredited_provider: @ratifying_provider,
    )

    @course_option = create(:course_option, :full_time, course: @course)
    @part_time_option = create(:course_option, :part_time, course: @course)
    @different_site_option = create(:course_option, :full_time, course: @course)

    @application_form = build(:application_form, :completed)
    @application_choice = create(:application_choice, :pending_conditions,
                                 application_form: @application_form,
                                 course_option: @course_option)
    create(
      :provider_permissions,
      provider: @another_provider,
      provider_user: @provider_user,
      make_decisions: true,
      set_up_interviews: true,
    )
    @another_provider_course = create(
      :course,
      name: "Mathematics",
      study_mode: :full_time_or_part_time,
      provider: @another_provider,
      accredited_provider: @ratifying_provider,
    )
    @source_provider_course = create(
      :course,
      name: "English",
      study_mode: :full_time_or_part_time,
      provider: @source_provider,
      accredited_provider: @ratifying_provider,
    )

    create(:course_option, :part_time, course: @another_provider_course)
    create(:course_option, :full_time, course: @another_provider_course)
    create(:course_option, :part_time, course: @source_provider_course)
    create(:course_option, :full_time, course: @source_provider_course)

    create(
      :provider_relationship_permissions,
      training_provider: @source_provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    create(
      :provider_relationship_permissions,
      training_provider: @another_provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :and_i_click, :when_i_click

  def when_i_chose_another_provider
    choose @another_provider.name
  end

  def when_i_choose_part_time
    choose 'Part time'
  end

  def then_i_review_the_selections(provider:, course:, study_mode:, site_postcode:)
    within('.govuk-summary-list__row:nth-of-type(1)') do
      expect(page).to have_content('Training provider')
      expect(page).to have_content(provider)
    end

    within('.govuk-summary-list__row:nth-of-type(2)') do
      expect(page).to have_content('Course')
      expect(page).to have_content(course)
    end

    within('.govuk-summary-list__row:nth-of-type(3)') do
      expect(page).to have_content('Full time or part time')
      expect(page).to have_content(study_mode)
    end

    within('.govuk-summary-list__row:nth-of-type(4)') do
      expect(page).to have_content(site_postcode)
    end
  end

  def then_the_application_choice_is_updated(provider:, course:, study_mode:, site:)
    @application_choice.reload
    expect(@application_choice.current_provider).to eq(provider)
    expect(@application_choice.current_course).to eq(course)
    expect(@application_choice.current_course_option.study_mode).to eq(study_mode)
    expect(@application_choice.current_course_option.site).to eq(site)
    expect(@application_choice.status).to eq('pending_conditions')
  end

  def when_i_chose_another_course
    choose @source_provider_course.name
  end

  def when_i_choose_a_different_site
    choose @different_site_option.site.name
  end
end
