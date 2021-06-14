require 'rails_helper'

RSpec.feature 'See application history', with_audited: true do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  scenario 'Support user visits application audit page' do
    given_i_am_a_support_user
    and_there_is_an_application_in_the_system_logged_by_a_candidate
    and_a_vendor_updates_the_application_status
    and_a_provider_updates_the_application_status
    and_i_visit_the_support_page

    when_i_click_on_an_application
    when_i_click_on_an_application_history
    then_i_should_be_able_to_see_history_events
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_in_the_system_logged_by_a_candidate
    candidate = create :candidate, email_address: 'alice@example.com'
    @provider = create(:provider)

    Audited.audit_class.as_user(candidate) do
      application_form = create(
        :completed_application_form,
        first_name: 'Alice',
        last_name: 'Wunder',
        candidate: candidate,
      )
      Timecop.travel(1.second.from_now) do
        @application_choice = create(
          :application_choice,
          :awaiting_provider_decision,
          application_form: application_form,
          course_option: course_option_for_provider(provider: @provider),
        )
      end
    end
  end

  def and_a_vendor_updates_the_application_status
    vendor_api_user = create :vendor_api_user, email_address: 'bob@example.com'
    vendor_api_user.vendor_api_token.update(provider_id: @provider.id)

    Timecop.travel(1.day.from_now) do
      Audited.audit_class.as_user(vendor_api_user) do
        RejectApplication.new(actor: vendor_api_user, application_choice: @application_choice, rejection_reason: 'BAD BAD BAD!').save
      end
    end
  end

  def and_a_provider_updates_the_application_status
    provider_user = create :provider_user, email_address: 'derek@example.com', dfe_sign_in_uid: '123', providers: [@provider]
    permit_make_decisions!(dfe_sign_in_uid: '123')
    update_conditions_service = UpdateOfferConditions.new(application_choice: @application_choice, conditions: [])

    Timecop.travel(2.days.from_now) do
      Audited.audit_class.as_user(provider_user) do
        MakeOffer.new(actor: provider_user, application_choice: @application_choice, course_option: @application_choice.course_option, update_conditions_service: update_conditions_service).save!
      end
    end
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_on 'Alice Wunder'
  end

  def when_i_click_on_an_application_history
    click_on 'History'
  end

  def then_i_should_be_able_to_see_history_events
    expect(page).to have_content 'status rejected → offer'
    expect(page).to have_content 'status awaiting_provider_decision → rejected'
    expect(page).to have_content 'status awaiting_provider_decision'
    expect(page).to have_content 'Create Application Form'
  end
end
