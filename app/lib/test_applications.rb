require 'active_support/testing/time_helpers'
require 'sidekiq/testing'

module TestApplications
  class NotEnoughCoursesError < RuntimeError; end
  class ZeroCoursesPerApplicationError < RuntimeError; end

  extend ActiveSupport::Testing::TimeHelpers

  def self.generate_for_provider(provider:, courses_per_application:, count:)
    1.upto(count).flat_map do
      create_application(
        states: [:awaiting_provider_decision] * courses_per_application,
        courses_to_apply_to: Course.open_on_apply.where(provider: provider),
      )
    end
  end

  def self.create_application(states:, courses_to_apply_to: nil)
    travel_to rand(30..60).days.ago
    raise ZeroCoursesPerApplicationError.new('You can\'t have zero courses per application') unless states.any?

    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    candidate = FactoryBot.create(
      :candidate,
      email_address: "#{first_name.downcase}.#{last_name.downcase}@example.com",
    )

    courses_to_apply_to ||= Course.joins(:course_options)
      .open_on_apply

    courses_to_apply_to = courses_to_apply_to.sample(states.count)

    # it does not make sense to apply to the same course multiple times
    # in the course of the same application, and it’s forbidden in the UI.
    # Throw an exception if we try to do that here.
    if courses_to_apply_to.count < states.count
      raise NotEnoughCoursesError.new("Not enough distinct courses to generate a #{states.count}-course application")
    end

    Audited.audit_class.as_user(candidate) do
      fast_forward(1..2)
      application_form = FactoryBot.create(
        :completed_application_form,
        application_choices_count: 0,
        full_work_history: true,
        volunteering_experiences_count: 1,
        references_count: 2,
        with_gces: true,
        submitted_at: nil,
        candidate: candidate,
        first_name: first_name,
        last_name: last_name,
      )

      application_choices = courses_to_apply_to.map do |course|
        FactoryBot.create(
          :application_choice,
          status: 'unsubmitted',
          course_option: course.course_options.first,
          application_form: application_form,
          personal_statement: Faker::Lorem.paragraph(sentence_count: 5),
        )
      end

      return if states.include? :unsubmitted

      fast_forward(1..2)
      without_slack_message_sending do
        SubmitApplication.new(application_form).call
        return if states.include? :awaiting_references

        application_form.application_references.each do |reference|
          reference.relationship_correction = [nil, Faker::Lorem.sentence].sample
          reference.safeguarding_concerns = [nil, Faker::Lorem.sentence].sample

          fast_forward(1..2)

          ReceiveReference.new(
            reference: reference,
            feedback: 'You are awesome',
          ).save!
        end
        return if states.include? :application_complete

        application_choices.map(&:reload)

        states.zip(application_choices).each do |state, application_choice|
          put_application_choice_in_state(application_choice, state)
        end
      end

      application_choices
    end
  ensure
    travel_back
  end

  def self.put_application_choice_in_state(choice, state)
    travel_to(choice.edit_by) if choice.edit_by > Time.zone.now
    SendApplicationToProvider.new(application_choice: choice).call
    return if state == :awaiting_provider_decision

    if state == :offer
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS']).save
    elsif state == :rejected
      fast_forward(1..3)
      RejectApplication.new(application_choice: choice, rejection_reason: 'Some').save
    elsif state == :offer_withdrawn
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS']).save
      fast_forward(1..3)
      WithdrawOffer.new(application_choice: choice, offer_withdrawal_reason: 'Offer withdrawal reason is...').save
    elsif state == :declined
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS']).save
      fast_forward(1..3)
      DeclineOffer.new(application_choice: choice).save!
    elsif state == :accepted
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS', 'Fitness to teach check']).save
      fast_forward(1..3)
      AcceptOffer.new(application_choice: choice).save!
    elsif state == :accepted_no_conditions
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: []).save
      fast_forward(1..3)
      AcceptOffer.new(application_choice: choice).save!
    elsif state == :conditions_not_met
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS', 'Fitness to teach check', 'Complete course']).save
      fast_forward(1..3)
      AcceptOffer.new(application_choice: choice).save!
      fast_forward(1..3)
      ConditionsNotMet.new(application_choice: choice).save
    elsif state == :recruited
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS', 'Fitness to teach check']).save
      fast_forward(1..3)
      AcceptOffer.new(application_choice: choice).save!
      fast_forward(1..3)
      ConfirmOfferConditions.new(application_choice: choice).save
    elsif state == :enrolled
      fast_forward(1..3)
      MakeAnOffer.new(actor: actor, application_choice: choice, offer_conditions: ['Complete DBS']).save
      fast_forward(1..3)
      AcceptOffer.new(application_choice: choice).save!
      fast_forward(1..3)
      ConfirmOfferConditions.new(application_choice: choice).save
      fast_forward(1..3)
      ConfirmEnrolment.new(application_choice: choice).save
    elsif state == :withdrawn
      fast_forward(1..3)
      WithdrawApplication.new(application_choice: choice).save!
    end
  end

  def self.actor
    SupportUser.first_or_initialize
  end

  def self.without_slack_message_sending
    RequestStore.store[:disable_slack_messages] = true
    yield
    RequestStore.store[:disable_slack_messages] = false
  end

  def self.fast_forward(range)
    travel_to(Time.zone.now + rand(range).days)
  end
end
