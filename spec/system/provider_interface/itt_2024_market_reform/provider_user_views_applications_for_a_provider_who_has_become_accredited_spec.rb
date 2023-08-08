require 'rails_helper'

RSpec.feature 'ITT 2024 market reform – viewing applications after a provider gains accreditation' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider user signs in and visits the application page' do
    when_the_2023_cycle_is_open
    and_there_are_applications_in_2023
    and_i_sign_in_as_the_partner_provider_that_will_gain_accreditation
    then_i_see_the_correct_2023_applications_for_the_partner_provider_that_will_gain_accreditation

    when_i_sign_in_as_the_first_accredited_provider
    then_i_see_the_correct_2023_applications_for_the_first_accredited_provider

    when_i_sign_in_as_the_second_accredited_provider
    then_i_see_the_correct_2023_applications_for_the_second_accredited_provider

    when_i_sign_in_as_the_partner_provider
    then_i_see_the_correct_2023_applications_for_the_partner_provider

    when_the_2024_cycle_is_open
    and_there_are_applications_in_2024
    and_i_sign_in_as_the_partner_provider_that_will_gain_accreditation
    then_i_see_the_correct_2024_applications_for_the_partner_provider_that_gained_accreditation

    when_i_sign_in_as_the_first_accredited_provider
    then_i_see_the_correct_2024_applications_for_the_first_accredited_provider

    when_i_sign_in_as_the_second_accredited_provider
    then_i_see_the_correct_2024_applications_for_the_second_accredited_provider

    when_i_sign_in_as_the_partner_provider
    then_i_see_the_correct_2024_applications_for_the_partner_provider
  end

  def when_the_2023_cycle_is_open
    TestSuiteTimeMachine.travel_permanently_to(2023, 3, 1)

    @partner_provider_who_will_gain_accreditation_in_2024 = create(:provider, name: 'partner_provider_one', code: '123')
    @partner_provider_who_will_gain_accreditation_in_2024_user = create(:provider_user, :with_notifications_enabled, providers: [@partner_provider_who_will_gain_accreditation_in_2024], dfe_sign_in_uid: 'partner_provider_one', email_address: 'partner_provider_one@example.com')

    @first_accredited_provider = create(:provider, name: 'provider_one', code: '456')
    @first_accredited_provider_user = create(:provider_user, :with_notifications_enabled, providers: [@first_accredited_provider], dfe_sign_in_uid: 'provider_one', email_address: 'provider_one@example.com')

    @second_accredited_provider = create(:provider, name: 'provider_two', code: '789')
    @second_accredited_provider_user = create(:provider_user, :with_notifications_enabled, providers: [@second_accredited_provider], dfe_sign_in_uid: 'provider_two', email_address: 'provider_two@example.com')

    @partner_provider = create(:provider, name: 'partner_provider_two', code: '100')
    @partner_provider_user = create(:provider_user, :with_notifications_enabled, providers: [@partner_provider], dfe_sign_in_uid: 'partner_provider_two', email_address: 'partner_provider_two@example.com')

    @partner_provider_who_will_gain_accreditation_2023_course_ratified_by_first_accredited_provider = course_option_for_accredited_provider(provider: @partner_provider_who_will_gain_accreditation_in_2024, accredited_provider: @first_accredited_provider, recruitment_cycle_year: 2023)
    @partner_provider_who_will_gain_accreditation_2023_course_ratified_by_second_accredited_provider = course_option_for_accredited_provider(provider: @partner_provider_who_will_gain_accreditation_in_2024, accredited_provider: @second_accredited_provider, recruitment_cycle_year: 2023)

    @second_accredited_provider_2023_self_ratified_course = course_option_for_provider(provider: @second_accredited_provider, recruitment_cycle_year: 2023)

    @partner_provider_2023_course_ratified_by_second_accredited_provider = course_option_for_accredited_provider(provider: @partner_provider, accredited_provider: @second_accredited_provider, recruitment_cycle_year: 2023)
  end

  def and_there_are_applications_in_2023
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_who_will_gain_accreditation_2023_course_ratified_by_first_accredited_provider, application_form: create(:application_form, first_name: 'I applied to the partner provider who will gain accreditation 2023 course ratified by the first accredited provider', recruitment_cycle_year: 2023))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_who_will_gain_accreditation_2023_course_ratified_by_second_accredited_provider, application_form: create(:application_form, first_name: 'I applied to the partner provider who will gain accreditation 2023 course ratified by the second accredited provider', recruitment_cycle_year: 2023))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @second_accredited_provider_2023_self_ratified_course, application_form: create(:application_form, first_name: 'I applied to the 2023 course self ratified by the second accredited provider', recruitment_cycle_year: 2023))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_2023_course_ratified_by_second_accredited_provider, application_form: create(:application_form, first_name: 'I applied to the partner provider 2023 course ratified by the second accredited provider', recruitment_cycle_year: 2023))
  end

  def and_i_sign_in_as_the_partner_provider_that_will_gain_accreditation
    sign_in_as(email_address: 'partner_provider_one@example.com', dfe_sign_in_uid: 'partner_provider_one')
  end

  def then_i_see_the_correct_2023_applications_for_the_partner_provider_that_will_gain_accreditation
    expect(page).to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the first accredited provider'
    expect(page).to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the second accredited provider'

    expect(page).not_to have_link 'I applied to the 2023 course self ratified by the second accredited provider'
    expect(page).not_to have_link 'I applied to the partner provider 2023 course ratified by the second accredited provider'
  end

  def when_i_sign_in_as_the_second_accredited_provider
    sign_in_as(email_address: 'provider_two@example.com', dfe_sign_in_uid: 'provider_two')
  end

  def then_i_see_the_correct_2023_applications_for_the_second_accredited_provider
    expect(page).to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the second accredited provider'
    expect(page).to have_link 'I applied to the partner provider 2023 course ratified by the second accredited provider'
    expect(page).to have_link 'I applied to the 2023 course self ratified by the second accredited provider'
  end

  def when_i_sign_in_as_the_first_accredited_provider
    sign_in_as(email_address: 'provider_one@example.com', dfe_sign_in_uid: 'provider_one')
  end

  def then_i_see_the_correct_2023_applications_for_the_first_accredited_provider
    expect(page).to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the first accredited provider'

    expect(page).not_to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the second accredited provider'
    expect(page).not_to have_link 'I applied to the partner provider 2023 course ratified by the second accredited provider'
    expect(page).not_to have_link 'I applied to the 2023 course self ratified by the second accredited provider'
  end

  def when_i_sign_in_as_the_partner_provider
    sign_in_as(email_address: 'partner_provider_two@example.com', dfe_sign_in_uid: 'partner_provider_two')
  end

  def then_i_see_the_correct_2023_applications_for_the_partner_provider
    expect(page).to have_link 'I applied to the partner provider 2023 course ratified by the second accredited provider'

    expect(page).not_to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the first accredited provider'
    expect(page).not_to have_link 'I applied to the partner provider who will gain accreditation 2023 course ratified by the second accredited provider'
    expect(page).not_to have_link 'I applied to the 2023 course self ratified by the second accredited provider'
  end

  def when_the_2024_cycle_is_open
    TestSuiteTimeMachine.travel_permanently_to(2024, 3, 1)

    @provider_who_gained_accreditation_2024_self_ratified_course = course_option_for_provider(provider: @partner_provider_who_will_gain_accreditation_in_2024, recruitment_cycle_year: 2024)

    @second_accredited_provider_2024_self_ratified_course = course_option_for_provider(provider: @second_accredited_provider, recruitment_cycle_year: 2024)

    @first_accredited_provider_self_ratified_2024_course = course_option_for_provider(provider: @first_accredited_provider, recruitment_cycle_year: 2024)

    @partner_provider_2024_course_ratified_by_provider_who_gained_accreditation_in_2024 = course_option_for_accredited_provider(provider: @partner_provider, accredited_provider: @partner_provider_who_will_gain_accreditation_in_2024, recruitment_cycle_year: 2024)
    @partner_provider_2024_course_ratified_by_second_accredited_provider = course_option_for_accredited_provider(provider: @partner_provider, accredited_provider: @second_accredited_provider, recruitment_cycle_year: 2024, permissions_required: false)
  end

  def and_there_are_applications_in_2024
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @provider_who_gained_accreditation_2024_self_ratified_course, application_form: create(:application_form, first_name: 'I applied to the 2024 course self ratified by the provider that gained accreditation', recruitment_cycle_year: 2024))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @second_accredited_provider_2024_self_ratified_course, application_form: create(:application_form, first_name: 'I applied to the 2024 course self ratified by the second accredited proivder', recruitment_cycle_year: 2024))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @first_accredited_provider_self_ratified_2024_course, application_form: create(:application_form, first_name: 'I applied to the 2024 course self ratified by the first accredited provider', recruitment_cycle_year: 2024))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_2024_course_ratified_by_provider_who_gained_accreditation_in_2024, application_form: create(:application_form, first_name: 'I applied to the 2024 partner provider course that is ratified by the provider that gained accreditation', recruitment_cycle_year: 2024))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: @partner_provider_2024_course_ratified_by_second_accredited_provider, application_form: create(:application_form, first_name: 'I applied to the 2024 partner provider course ratified by the second accredited provider', recruitment_cycle_year: 2024))
  end

  def then_i_see_the_correct_2024_applications_for_the_partner_provider_that_gained_accreditation
    expect(page).to have_link 'I applied to the 2024 course self ratified by the provider that gained accreditation'
    expect(page).to have_link 'I applied to the 2024 partner provider course that is ratified by the provider that gained accreditation'

    expect(page).not_to have_link 'I applied to the 2024 course self ratified by the second accredited proivder'
    expect(page).not_to have_link 'I applied to the 2024 course self ratified by the first accredited provider'
  end

  def then_i_see_the_correct_2024_applications_for_the_second_accredited_provider
    expect(page).to have_link 'I applied to the 2024 course self ratified by the second accredited proivder'
    expect(page).to have_link 'I applied to the 2024 partner provider course ratified by the second accredited provider'

    expect(page).not_to have_link 'I applied to the 2024 partner provider course that is ratified by the provider that gained accreditation'
    expect(page).not_to have_link 'I applied to the 2024 course self ratified by the provider that gained accreditation'
  end

  def then_i_see_the_correct_2024_applications_for_the_first_accredited_provider
    expect(page).to have_link 'I applied to the 2024 course self ratified by the first accredited provider'

    expect(page).not_to have_link 'I applied to the 2024 course self ratified by the provider that gained accreditation'
  end

  def then_i_see_the_correct_2024_applications_for_the_partner_provider
    expect(page).to have_link 'I applied to the 2024 partner provider course that is ratified by the provider that gained accreditation'
    expect(page).to have_link 'I applied to the 2024 partner provider course ratified by the second accredited provider'

    expect(page).not_to have_link 'I applied to the 2024 course self ratified by the provider that gained accreditation'
  end
end
