require 'rails_helper'

RSpec.feature 'Receives rejection email' do
  include CandidateHelper

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  scenario 'Receives rejection email' do
    given_the_pilot_is_open

    when_all_but_one_of_my_application_choices_have_been_rejected
    and_a_provider_rejects_my_application
    then_i_receive_the_all_applications_rejected_email

    when_i_am_awaiting_decisions_and_have_no_offers
    and_a_provider_rejects_my_application
    then_i_receive_the_application_rejected_awaiting_decisions_email

    when_i_have_a_single_offer
    and_a_provider_rejects_my_application
    then_i_receive_the_application_rejected_offers_made_email
    and_it_includes_details_of_my_offer

    when_i_have_multiple_offers
    and_a_provider_rejects_my_application
    then_i_receive_the_application_rejected_offers_made_email
    and_it_includes_details_of_my_offers
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_all_but_one_of_my_application_choices_have_been_rejected
    @application_form = create(:completed_application_form)
    create_list(:application_choice, 2, status: :rejected, application_form: @application_form)
    @application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
  end

  def when_i_am_awaiting_decisions_and_have_no_offers
    @application_form = create(:completed_application_form)
    create_list(:application_choice, 2, status: :awaiting_provider_decision, reject_by_default_at: 10.business_days.from_now, application_form: @application_form)
    @application_choice = @application_form.application_choices.first
  end

  def when_i_have_a_single_offer
    @application_form = create(:completed_application_form)
    @offer = create(:application_choice, :with_offer, application_form: @application_form)
    @application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
  end

  def when_i_have_multiple_offers
    @application_form = create(:completed_application_form)
    @offer = create(:application_choice, :with_offer, application_form: @application_form)
    @offer2 = create(:application_choice, :with_offer, application_form: @application_form)
    @application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
  end

  def and_a_provider_rejects_my_application
    RejectApplication.new(
      actor: create(:support_user),
      application_choice: @application_choice,
      rejection_reason: 'No experience working with children.',
    ).save
  end

  def then_i_receive_the_all_applications_rejected_email
    open_email(@application_form.candidate.email_address)

    expect(current_email.subject).to include(I18n.t!('candidate_mailer.application_rejected_all_applications_rejected.subject', provider_name: @application_choice.provider.name))
  end

  def then_i_receive_the_application_rejected_awaiting_decisions_email
    open_email(@application_form.candidate.email_address)

    expect(current_email.subject).to include(I18n.t!('candidate_mailer.application_rejected_awaiting_decision_only.subject', provider_name: @application_choice.provider.name, course_name: @application_choice.course.name))
  end

  def then_i_receive_the_application_rejected_offers_made_email
    open_email(@application_form.candidate.email_address)

    expect(current_email.subject).to include(I18n.t!('candidate_mailer.application_rejected_offers_only.subject', date: @offer.decline_by_default_at.to_s(:govuk_date)))
  end

  def and_it_includes_details_of_my_offer
    expect(current_email.text).to include(@offer.provider.name)
    expect(current_email.text).to include(@offer.course.name)

    expect(current_email.text).to include("The offer will automatically be withdrawn if you do not respond by #{@offer.decline_by_default_at.to_s(:govuk_date)}")
  end

  def and_it_includes_details_of_my_offers
    expect(current_email.text).to include(@offer.provider.name)
    expect(current_email.text).to include(@offer.course.name)
    expect(current_email.text).to include(@offer2.provider.name)
    expect(current_email.text).to include(@offer2.course.name)
    expect(current_email.text).to include("The offers will automatically be withdrawn if you do not respond by #{@offer.decline_by_default_at.to_s(:govuk_date)}")
  end
end
