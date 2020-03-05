module TestHelpers
  module MailerSetupHelper
    def setup_application
      @candidate = build_stubbed(:candidate)
      @application_form = build_stubbed(
        :completed_application_form,
        support_reference: 'SUPPORT-REFERENCE',
        first_name: 'Bob',
        candidate: @candidate,
        references_count: 1,
      )
      provider = build_stubbed(:provider, name: 'Brighthurst Technical College')
      course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider: provider))

      @application_choice = @application_form.application_choices.build(
        application_form: @application_form,
        course_option: course_option,
        status: :offer,
        offer: { conditions: ['DBS check', 'Pass exams'] },
        offered_course_option: course_option,
        decline_by_default_at: 10.business_days.from_now,
        reject_by_default_days: 10,
      )
    end

    def setup_application_form_with_two_offers(application_form)
      first_provider = build_stubbed(:provider, name: 'Wen University')
      first_course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'MS Painting', code: 'P00', provider: first_provider))
      first_application_choice_with_offer = application_form.application_choices.build(
        application_form: application_form,
        course_option: first_course_option,
        status: :offer,
        decline_by_default_at: 10.business_days.from_now,
        decline_by_default_days: 10,
      )

      second_provider = build_stubbed(:provider, name: 'Ting University')
      second_course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Code Refactoring', code: 'Z00', provider: second_provider))
      second_application_choice_with_offer = application_form.application_choices.build(
        application_form: application_form,
        course_option: second_course_option,
        status: :offer,
        decline_by_default_at: 10.business_days.from_now,
        decline_by_default_days: 10,
      )

      application_form.application_choices = application_form.application_choices + [first_application_choice_with_offer, second_application_choice_with_offer]
    end
  end
end
