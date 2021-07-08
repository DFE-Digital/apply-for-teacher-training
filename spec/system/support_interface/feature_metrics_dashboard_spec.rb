require 'rails_helper'

RSpec.feature 'Feature metrics dashboard' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View feature metrics', with_audited: true do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system
    and_the_feature_metrics_dashboard_has_been_updated

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_feature_metrics_link

    then_i_should_see_reference_metrics
    and_i_should_see_work_history_metrics
    and_i_should_see_accessing_the_service_metrics
    and_i_should_see_reasons_for_rejection_metrics
    and_i_should_see_apply_again_metrics
    and_i_should_see_carry_over_metrics
    and_i_should_see_satisfaction_survey_metrics
    and_i_should_see_equality_and_diversity_metrics
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def create_application_form_with_references(attrs = {})
    application_form = create(:application_form, attrs)
    create(:application_choice, application_form: application_form)
    references = create_list(:reference, 2, application_form: application_form)
    references.each { |reference| RequestReference.new.call(reference) }
    [application_form, references]
  end

  def provide_references(references)
    references.each { |reference| SubmitReference.new(reference: reference, send_emails: false).save! }
  end

  def start_work_history(application_form)
    create(:application_work_experience, application_form: application_form)
  end

  def complete_work_history(application_form)
    application_form.update!(work_history_completed: true)
  end

  def reject_application(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: { qualifications_y_n: 'Yes' },
      rejected_at: Time.zone.now,
    )
  end

  def carry_over_application(application_form)
    DuplicateApplication.new(
      application_form,
      target_phase: 'apply_1',
    ).duplicate
  end

  def apply_again_and_offer_application(application_form)
    apply_again_application_form = DuplicateApplication.new(
      application_form,
      target_phase: 'apply_2',
    ).duplicate
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: apply_again_application_form,
    )
    ApplicationStateChange.new(application_choice).make_offer!
    apply_again_application_form
  end

  def apply_again_and_reject_application(application_form)
    apply_again_application_form = DuplicateApplication.new(
      application_form,
      target_phase: 'apply_2',
    ).duplicate
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: apply_again_application_form,
    )
    ApplicationStateChange.new(application_choice).reject!
    apply_again_application_form
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    ApplicationForm.with_unsafe_application_choice_touches do
      allow(CycleTimetable).to receive(:apply_reopens).and_return(60.days.ago)
      Timecop.freeze(@today - 65.days) do
        @previous_application_form = create_application_form_with_references(recruitment_cycle_year: 2020).first
      end
      Timecop.freeze(@today - 50.days) do
        @application_form1, @references1 = create_application_form_with_references
        @application_form2, @references2 = create_application_form_with_references
        create(:authentication_token, user: @application_form1.candidate, hashed_token: '0987654321')
        create(:authentication_token, user: @application_form1.candidate, hashed_token: '9876543210')
        create(:authentication_token, user: @application_form2.candidate, hashed_token: '8765432109')
        start_work_history(@application_form1)
      end
      Timecop.freeze(@today - 40.days) do
        @application_form3, @references3 = create_application_form_with_references
        provide_references(@references1)
        start_work_history(@application_form2)
        complete_work_history(@application_form1)
        reject_application(@application_form1.application_choices.first)
      end
      Timecop.freeze(@today - 21.days) do
        @application_form4, @references4 = create_application_form_with_references
        provide_references(@references2)
        complete_work_history(@application_form2)
        start_work_history(@application_form3)
        start_work_history(@application_form4)
      end
      Timecop.freeze(@today - 2.days) do
        provide_references(@references3)
        provide_references(@references4)
        complete_work_history(@application_form3)
        complete_work_history(@application_form4)
        reject_application(@application_form2.application_choices.first)
        apply_again_and_reject_application(@application_form1)
        apply_again_and_offer_application(@application_form2)
        carry_over_application(@previous_application_form)
      end
    end
  end

  def and_the_feature_metrics_dashboard_has_been_updated
    UpdateFeatureMetricsDashboard.new.perform
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def and_i_click_on_the_feature_metrics_link
    click_on 'Feature metrics'
  end

  def then_i_should_see_reference_metrics
    expect(page).to have_content('Feature metrics')
    within('[data-qa="section-references"]') do
      expect(page).to have_content('24 days average time to get reference back')
      expect(page).to have_content('10 days last month')
      expect(page).to have_content('28.7 days this month')
      expect(page).to have_content('75% completed within 30 days')
      expect(page).to have_content('100% last month')
      expect(page).to have_content('66.7% this month')
    end
  end

  def and_i_should_see_work_history_metrics
    within('[data-qa="section-work-history"]') do
      expect(page).to have_content('16.8 days time to complete')
      expect(page).to have_content('19 days this month')
      expect(page).to have_content('10 days last month')
    end
  end

  def and_i_should_see_accessing_the_service_metrics
    within('[data-qa="section-accessing-the-service"]') do
      expect(page).to have_content('0.8 average number of sign-ins before submitting application')
      expect(page).to have_content('0 this month')
      expect(page).to have_content('1 last month')
    end
  end

  def and_i_should_see_reasons_for_rejection_metrics
    within('[data-qa="section-reasons-for-rejection"]') do
      expect(page).to have_content('2 rejections due to qualifications')
      expect(page).to have_content('1 last month')
      expect(page).to have_content('1 this month')
    end
  end

  def and_i_should_see_apply_again_metrics
    within('[data-qa="section-apply-again"]') do
      expect(page).to have_content('50% apply again success rate')
      expect(page).to have_content('n/a upto this month')
      expect(page).to have_content('50% this month')
    end
  end

  def and_i_should_see_carry_over_metrics
    within('[data-qa="section-carry-over"]') do
      expect(page).to have_content('1 candidates carried over applications from previous cycle')
      expect(page).to have_content('0 last month')
      expect(page).to have_content('1 this month')
    end
  end

  def and_i_should_see_satisfaction_survey_metrics
    within('[data-qa="section-satisfaction-survey"]') do
      expect(page).to have_content('n/a response rate')
      expect(page).to have_content('n/a last month')
      expect(page).to have_content('n/a this month')
      expect(page).to have_content('n/a satisfied or very satisfied')
    end
  end

  def and_i_should_see_equality_and_diversity_metrics
    within('[data-qa="section-equality-and-diversity"]') do
      expect(page).to have_content('n/a response rate')
      expect(page).to have_content('n/a last month')
      expect(page).to have_content('n/a this month')
    end
  end
end
