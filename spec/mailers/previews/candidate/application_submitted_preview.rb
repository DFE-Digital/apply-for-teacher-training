class Candidate::ApplicationSubmittedPreview < ActionMailer::Preview
  def application_choice_submitted
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate:,
      support_reference: 'ABCDEF',
      application_choices: [],
    )
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision, course_option:, application_form:)

    CandidateMailer.application_choice_submitted(application_choice)
  end

  def application_choice_submitted_with_christmas_delay_warning
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate:,
      support_reference: 'ABCDEF',
      application_choices: [],
    )
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :awaiting_provider_decision,
      course_option:,
      application_form:,
      sent_to_provider_at: DateTime.new(RecruitmentCycleTimetable.current_year, 1, 1),
    )

    CandidateMailer.application_choice_submitted(application_choice)
  end

  def application_choice_submitted_with_easter_delay_warning
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate:,
      support_reference: 'ABCDEF',
      application_choices: [],
    )

    year = RecruitmentCycleTimetable.current_year
    good_friday = Holidays.between(Time.zone.local(year, 1, 1), Time.zone.local(year, 6, 1), :gb_eng, :observed).find do |h|
      h[:name] == 'Good Friday'
    end[:date]

    sent_to_provider_at = 2.business_days.before(good_friday)

    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :awaiting_provider_decision,
      course_option:,
      application_form:,
      sent_to_provider_at:,
    )

    CandidateMailer.application_choice_submitted(application_choice)
  end

  def change_course
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision,
                                                  course_option:,
                                                  current_course_option: course_option)

    CandidateMailer.change_course(application_choice, application_choice.original_course_option)
  end

  def change_course_pending_conditions
    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course, provider:)
    site = FactoryBot.create(:site, provider:)
    course_option = FactoryBot.create(:course_option, course:, site:)
    original_course = FactoryBot.create(:course, provider:)
    original_course_option = FactoryBot.create(
      :course_option,
      course: original_course,
      site:,
    )

    offer = FactoryBot.create(
      :offer,
      conditions: [
        FactoryBot.create(:reference_condition),
        FactoryBot.create(:text_condition),
        FactoryBot.create(:ske_condition),
      ],
    )
    application_choice = FactoryBot.create(
      :application_choice,
      :pending_conditions,
      offer:,
      status: 'pending_conditions',
      course_option:,
      current_course_option: course_option,
      original_course_option:,
    )

    CandidateMailer.change_course_pending_conditions(
      application_choice,
      application_choice.original_course_option,
    )
  end

  def apply_to_another_course_after_30_working_days
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
      application_choices: [
        FactoryBot.create(
          :application_choice,
          :inactive,
        ),
      ],
    )

    CandidateMailer.apply_to_another_course_after_30_working_days(application_form)
  end

  def apply_to_another_course_after_30_working_days_with_holiday_warning
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
      application_choices: [
        FactoryBot.create(
          :application_choice,
          :inactive,
          sent_to_provider_at: DateTime.new(RecruitmentCycleTimetable.current_year, 1, 1),
        ),
      ],
    )

    CandidateMailer.apply_to_another_course_after_30_working_days(application_form)
  end

  def apply_to_multiple_courses_after_30_working_days
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
      application_choices: FactoryBot.create_list(
        :application_choice,
        2,
        :inactive,
      ),
    )

    CandidateMailer.apply_to_multiple_courses_after_30_working_days(application_form)
  end

  def apply_to_multiple_courses_after_30_working_days_with_holiday_response_time_warning
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
      application_choices: FactoryBot.create_list(
        :application_choice,
        2,
        :inactive,
        sent_to_provider_at: DateTime.new(RecruitmentCycleTimetable.current_year, 1, 1),
      ),
    )

    CandidateMailer.apply_to_multiple_courses_after_30_working_days(application_form)
  end

private

  def candidate
    @candidate ||= FactoryBot.build_stubbed(:candidate)
  end

  def course
    FactoryBot.build_stubbed(:course, provider:)
  end

  def provider
    FactoryBot.build_stubbed(:provider)
  end

  def site
    @site ||= FactoryBot.build_stubbed(:site, code: '-', name: 'Main site')
  end

  def course_option
    FactoryBot.build_stubbed(:course_option, course:, site:)
  end
end
