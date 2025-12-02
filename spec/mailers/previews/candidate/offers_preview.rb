class Candidate::OffersPreview < ActionMailer::Preview
  def offer_10_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_10_day(application_choice_with_offer)
  end

  def offer_20_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_20_day(application_choice_with_offer)
  end

  def offer_30_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_30_day(application_choice_with_offer)
  end

  def offer_40_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_40_day(application_choice_with_offer)
  end

  def offer_50_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_50_day(application_choice_with_offer)
  end

  def new_offer_made
    application_form_with_name = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
    )

    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form_with_name,
      course_option:,
      offer: FactoryBot.build(:offer, :with_unmet_conditions),
    )

    CandidateMailer.new_offer_made(application_choice)
  end

  def offer_withdrawn
    candidate = FactoryBot.build_stubbed(:candidate)
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      offer_withdrawal_reason: Faker::Lorem.sentence,
      application_form: FactoryBot.build_stubbed(:application_form, first_name: 'Geoff', candidate:),
    )
    CandidateMailer.offer_withdrawn(application_choice)
  end

  def offer_withdrawn_with_course_recommendation
    candidate = FactoryBot.build_stubbed(:candidate)
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      offer_withdrawal_reason: Faker::Lorem.sentence,
      application_form: FactoryBot.build_stubbed(:application_form, first_name: 'Geoff', candidate:),
    )
    CandidateMailer.offer_withdrawn(application_choice, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results')
  end

  def offer_accepted
    application_form_with_name = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
    )

    application_choice = FactoryBot.build_stubbed(:application_choice, application_form: application_form_with_name)
    CandidateMailer.offer_accepted(application_choice)
  end

  def conditions_statuses_changed
    met_conditions = FactoryBot.build_stubbed_list(:text_condition, 1)
    pending_conditions = FactoryBot.build_stubbed_list(:text_condition, 2)
    previously_met_conditions = FactoryBot.build_stubbed_list(:text_condition, 1)
    CandidateMailer.conditions_statuses_changed(application_choice_with_offer, met_conditions, pending_conditions, previously_met_conditions)
  end

  def conditions_met
    CandidateMailer.conditions_met(application_choice_with_offer)
  end

  def conditions_met_with_pending_ske_conditions
    application_choice = application_choice_pending_conditions.tap do |choice|
      choice.offer.conditions.first.status = :met
      choice.offer.ske_conditions = [FactoryBot.build_stubbed(:ske_condition, status: :pending)]
      choice.status = :recruited
      choice.current_course_option.provider.provider_type = :scitt
      choice.current_course_option.course.start_date = 1.month.from_now
    end

    CandidateMailer.conditions_met(application_choice)
  end

  def deferred_offer
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'pending_conditions', course_option:),
      ],
      candidate:,
    )

    CandidateMailer.deferred_offer(application_form.application_choices.first)
  end

  def deferred_offer_reminder
    course_option = FactoryBot.build_stubbed(
      :course_option,
      course: FactoryBot.build_stubbed(
        :course,
        recruitment_cycle_year: CycleTimetableHelper.previous_year,
      ),
    )

    application_choice = FactoryBot.build(
      :application_choice,
      :offer_deferred,
      course_option:,
      current_course_option: course_option,
      application_form:,
      offer_deferred_at: Time.zone.local(2020, 2, 3),
    )

    CandidateMailer.deferred_offer_reminder(application_choice)
  end

  def reinstated_offer_with_conditions
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :accepted,
      application_form:,
      course_option:,
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def reinstated_offer_without_conditions
    application_choice = FactoryBot.build(
      :application_choice,
      :recruited,
      application_form:,
      course_option:,
      offer: FactoryBot.build(:unconditional_offer),
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def deferred_offer_with_new_details_with_conditions
    provider = FactoryBot.create(:provider)
    course1 = FactoryBot.create(:course, provider:, name: 'Original course')
    course2 = FactoryBot.create(:course, provider:, name: 'New course')
    old_course_option = FactoryBot.create(:course_option, course: course1)
    course_option = FactoryBot.create(:course_option, course: course2)
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :accepted,
      application_form:,
      original_course_option: old_course_option,
      course_option:,
      school_placement_auto_selected: false,
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.deferred_offer_new_details(application_choice)
  end

  def deferred_offer_with_new_details_without_conditions
    provider = FactoryBot.create(:provider)
    course1 = FactoryBot.create(:course, provider:, name: 'Original course')
    course2 = FactoryBot.create(:course, provider:, name: 'New course')
    old_course_option = FactoryBot.create(:course_option, course: course1)
    course_option = FactoryBot.create(:course_option, course: course2)
    application_choice = FactoryBot.build(
      :application_choice,
      :recruited,
      application_form:,
      original_course_option: old_course_option,
      course_option:,
      school_placement_auto_selected: true,
      offer: FactoryBot.build(:unconditional_offer),
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.deferred_offer_new_details(application_choice)
  end

  def unconditional_offer_accepted
    application_form_with_name = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
    )
    application_choice = FactoryBot.build_stubbed(:application_choice, application_form: application_form_with_name)
    CandidateMailer.unconditional_offer_accepted(application_choice)
  end

  def changed_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision,
                                                  :offered,
                                                  course_option:,
                                                  application_form:,
                                                  current_course_option: course_option)

    CandidateMailer.changed_offer(application_choice)
  end

  def changed_unconditional_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build(:application_choice, :awaiting_provider_decision,
                                          :offered,
                                          offer: FactoryBot.build(:unconditional_offer),
                                          offered_at: Time.zone.now,
                                          current_course_option: course_option,
                                          course_option:,
                                          application_form:)

    CandidateMailer.changed_offer(application_choice)
  end

  def decline_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', course_option:),
      ],
      candidate:,
    )

    CandidateMailer.decline_last_application_choice(application_form.application_choices.first)
  end

  def decline_last_application_choice_with_course_recommendation
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', course_option:),
      ],
      candidate:,
    )

    CandidateMailer.decline_last_application_choice(application_form.application_choices.first, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results')
  end

private

  def application_form_with_course_choices(course_choices)
    FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      application_choices: course_choices,
      candidate:,
    )
  end

  def application_choice_pending_conditions
    provider = FactoryBot.build(:provider, name: 'Brighthurst Technical College')
    course = FactoryBot.build(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider: provider)
    course_option = FactoryBot.build(:course_option, course: course)

    FactoryBot.build(:application_choice,
                     :pending_conditions,
                     application_form:,
                     course_option: course_option,
                     sent_to_provider_at: 1.day.ago)
  end

  def application_choice_with_offer
    FactoryBot.build(:application_choice,
                     :offered,
                     application_form:,
                     course_option:,
                     sent_to_provider_at: 1.day.ago)
  end

  def course_option
    FactoryBot.build_stubbed(:course_option, course:, site:)
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate:)
  end

  def candidate
    @candidate ||= FactoryBot.build_stubbed(:candidate)
  end

  def provider
    FactoryBot.build_stubbed(:provider)
  end

  def course
    FactoryBot.build_stubbed(:course, provider:)
  end

  def site
    @site ||= FactoryBot.build_stubbed(:site, code: '-', name: 'Main site')
  end
end
