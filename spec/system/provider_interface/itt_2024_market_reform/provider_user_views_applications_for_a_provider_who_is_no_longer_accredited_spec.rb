require 'rails_helper'

RSpec.feature 'ITT 2024 market reform – viewing applications after a provider loses accreditation' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider user signs in and visits the application page' do
    when_the_2023_cycle_is_open
    and_there_are_applications_in_2023
    and_i_sign_in_as_the_provider_who_will_lose_accreditation
    then_i_see_the_correct_2023_applications_for_the_provider_who_will_lose_accreditation

    when_i_sign_in_as_the_provider_who_will_keep_accreditation
    then_i_see_the_correct_2023_applications_for_the_provider_who_will_keep_accreditation

    when_i_sign_in_as_the_partner_provider
    then_i_see_the_correct_2023_applications_for_the_partner_provider

    when_the_2024_cycle_is_open
    and_there_are_applications_in_2024
    and_i_sign_in_as_the_provider_who_will_lose_accreditation
    then_i_see_the_correct_2024_applications_for_the_provider_who_lost_accreditation

    when_i_sign_in_as_the_provider_who_will_keep_accreditation
    then_i_see_the_correct_2024_applications_for_the_provider_who_kept_accreditation

    when_i_sign_in_as_the_partner_provider
    then_i_see_the_correct_2024_applications_for_the_partner_provider
  end

  def when_the_2023_cycle_is_open
    TestSuiteTimeMachine.travel_permanently_to(2023, 3, 1)

    @provider_who_will_lose_accreditation_in_2024 = create(:provider, name: 'provider_one', code: '123')
    @provider_who_will_lose_accreditation_in_2024_user = create(:provider_user, :with_notifications_enabled, providers: [@provider_who_will_lose_accreditation_in_2024], dfe_sign_in_uid: 'provider_one', email_address: 'provider_one@example.com')
    @self_ratified_2023_course_for_provider_who_will_lose_accreditation_in_2024 = course_option_for_provider(provider: @provider_who_will_lose_accreditation_in_2024, recruitment_cycle_year: 2023)

    @partner_provider = create(:provider, name: 'partner_provider', code: '456')
    @partner_provider_user = create(:provider_user, :with_notifications_enabled, providers: [@partner_provider], dfe_sign_in_uid: 'partner_provider', email_address: 'partner_provider@example.com')
    @partner_provider_2023_course_ratified_by_provider_who_will_lose_accreditation_in_2024 = course_option_for_accredited_provider(provider: @partner_provider, accredited_provider: @provider_who_will_lose_accreditation_in_2024, recruitment_cycle_year: 2023)

    @provider_who_will_remain_accredited_in_2024 = create(:provider, name: 'provider_two', code: '789')
    @provider_who_will_remain_accredited_in_2024_user = create(:provider_user, :with_notifications_enabled, providers: [@provider_who_will_remain_accredited_in_2024], dfe_sign_in_uid: 'provider_two', email_address: 'provider_two@example.com')
    @partner_provider_2023_course_ratified_by_provider_who_will_keep_accreditation_in_2024 = course_option_for_accredited_provider(provider: @partner_provider, accredited_provider: @provider_who_will_remain_accredited_in_2024, recruitment_cycle_year: 2023)
  end

  def and_there_are_applications_in_2023
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @self_ratified_2023_course_for_provider_who_will_lose_accreditation_in_2024, application_form: create(:application_form, first_name: 'I applied for the 2023 course self ratified by the provider who will lose accreditation', recruitment_cycle_year: 2023))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_2023_course_ratified_by_provider_who_will_lose_accreditation_in_2024, application_form: create(:application_form, first_name: 'I applied for the 2023 partner course ratified by the provider who will lose accreditation', recruitment_cycle_year: 2023))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_2023_course_ratified_by_provider_who_will_keep_accreditation_in_2024, application_form: create(:application_form, first_name: 'I applied for the 2023 partner course ratified by the provider who will keep accreditation', recruitment_cycle_year: 2023))
  end

  def and_i_sign_in_as_the_provider_who_will_lose_accreditation
    sign_in_as(email_address: 'provider_one@example.com', dfe_sign_in_uid: 'provider_one')
  end

  def then_i_see_the_correct_2023_applications_for_the_provider_who_will_lose_accreditation
    expect(page).to have_link 'I applied for the 2023 course self ratified by the provider who will lose accreditation'
    expect(page).to have_link 'I applied for the 2023 partner course ratified by the provider who will lose accreditation'

    expect(page).to have_no_link 'I applied for the 2023 partner course ratified by the provider who will keep accreditation'
  end

  def when_i_sign_in_as_the_provider_who_will_keep_accreditation
    sign_in_as(email_address: 'provider_two@example.com', dfe_sign_in_uid: 'provider_two')
  end

  def then_i_see_the_correct_2023_applications_for_the_provider_who_will_keep_accreditation
    expect(page).to have_link 'I applied for the 2023 partner course ratified by the provider who will keep accreditation'

    expect(page).to have_no_link 'I applied for the 2023 course self ratified by the provider who will lose accreditation'
    expect(page).to have_no_link 'I applied for the 2023 partner course ratified by the provider who will lose accreditation'
  end

  def when_i_sign_in_as_the_partner_provider
    sign_in_as(email_address: 'partner_provider@example.com', dfe_sign_in_uid: 'partner_provider')
  end

  def then_i_see_the_correct_2023_applications_for_the_partner_provider
    expect(page).to have_link 'I applied for the 2023 partner course ratified by the provider who will lose accreditation'
    expect(page).to have_link 'I applied for the 2023 partner course ratified by the provider who will keep accreditation'

    expect(page).to have_no_link 'I applied for the 2023 course self ratified by the provider who will lose accreditation'
  end

  def when_the_2024_cycle_is_open
    TestSuiteTimeMachine.travel_permanently_to(2024, 3, 1)

    @partner_provider_2024_course_ratified_by_provider_kept_accreditation_in_2024 = course_option_for_accredited_provider(provider: @partner_provider, accredited_provider: @provider_who_will_remain_accredited_in_2024, recruitment_cycle_year: 2024, permissions_required: false)
    # Sussex course ratified by Chichester
    @provider_who_lost_accreditation_2024_course_ratified_by_provider_who_kept_accreditation_in_2024 = course_option_for_accredited_provider(provider: @provider_who_will_lose_accreditation_in_2024, accredited_provider: @provider_who_will_remain_accredited_in_2024, recruitment_cycle_year: 2024, permissions_required: false)
    # Chichester course – self ratified
    @self_ratified_2024_course_for_provider_who_kept_accreditiation_in_2024 = course_option_for_provider(provider: @provider_who_will_remain_accredited_in_2024, recruitment_cycle_year: 2024)
  end

  def and_there_are_applications_in_2024
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_2024_course_ratified_by_provider_kept_accreditation_in_2024, application_form: create(:application_form, first_name: 'I applied for the 2024 partner course ratified by the provider who kept accreditation', recruitment_cycle_year: 2024))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @provider_who_lost_accreditation_2024_course_ratified_by_provider_who_kept_accreditation_in_2024, application_form: create(:application_form, first_name: 'I applied for the 2024 course for the provider who lost accreditation and is now ratified by the provider who kept accreditation', recruitment_cycle_year: 2024))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @self_ratified_2024_course_for_provider_who_kept_accreditiation_in_2024, application_form: create(:application_form, first_name: 'I applied for the 2024 course self ratified by the provider who kept accreditation', recruitment_cycle_year: 2024))
  end

  def then_i_see_the_correct_2024_applications_for_the_provider_who_lost_accreditation
    expect(page).to have_link 'I applied for the 2024 course for the provider who lost accreditation and is now ratified by the provider who kept accreditation'

    expect(page).to have_no_link 'I applied for the 2024 partner course ratified by the provider who kept accreditation'
    expect(page).to have_no_link 'I applied for the 2024 course self ratified by the provider who kept accreditation'
  end

  def then_i_see_the_correct_2024_applications_for_the_provider_who_kept_accreditation
    expect(page).to have_link 'I applied for the 2024 partner course ratified by the provider who kept accreditation'
    expect(page).to have_link 'I applied for the 2024 course for the provider who lost accreditation and is now ratified by the provider who kept accreditation'
    expect(page).to have_link 'I applied for the 2024 course self ratified by the provider who kept accreditation'
  end

  def then_i_see_the_correct_2024_applications_for_the_partner_provider
    expect(page).to have_link 'I applied for the 2024 partner course ratified by the provider who kept accreditation'

    expect(page).to have_no_link 'I applied for the 2024 course for the provider who lost accreditation and is now ratified by the provider who kept accreditation'
    expect(page).to have_no_link 'I applied for the 2024 course self ratified by the provider who kept accreditation'
  end
end
