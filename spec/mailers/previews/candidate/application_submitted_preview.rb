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

  def change_course
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision,
                                                  course_option:,
                                                  current_course_option: course_option)

    CandidateMailer.change_course(application_choice, application_choice.original_course_option)
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
