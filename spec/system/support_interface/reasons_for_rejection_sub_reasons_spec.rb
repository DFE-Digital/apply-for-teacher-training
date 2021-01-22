require 'rails_helper'

RSpec.feature 'Reasons for rejection sub-reasons' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View reasons for rejection sub-reasons' do
    given_i_am_a_support_user
    and_there_are_candidates_and_rejected_applications_in_the_system

    when_i_visit_the_reasons_for_rejection_sub_reasons_page

    then_i_should_see_counts_for_rejection_sub_reasons
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def create_application
    application_form = create(:application_form)
    create(:application_choice, application_form: application_form)
  end

  def reject_application(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: { qualifications_y_n: 'Yes' },
      rejected_at: Time.zone.now,
    )
  end

  def and_there_are_candidates_and_rejected_applications_in_the_system
    Timecop.freeze(@today - 50.days) do
      @application_choice1 = create_application
    end
    Timecop.freeze(@today - 40.days) do
      @application_choice2 = create_application
      reject_application(@application_choice1)
    end
    Timecop.freeze(@today - 21.days) do
      @application_choice3 = create_application
      reject_application(@application_choice2)
    end
    Timecop.freeze(@today - 2.days) do
      reject_application(@application_choice3)
    end
  end

  def when_i_visit_the_reasons_for_rejection_sub_reasons_page
    visit support_interface_reasons_for_rejection_sub_reasons_path
  end

  def then_i_should_see_counts_for_rejection_sub_reasons
  end
end
