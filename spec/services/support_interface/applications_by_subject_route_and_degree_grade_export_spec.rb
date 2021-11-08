require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport do
  describe '#call' do
    it 'correctly breaks down subject choice by route' do
      drama = create(:subject, code: '13')
      first_application_form = create(:completed_application_form)
      create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: first_application_form)
      scitt_provider = create(:provider, provider_type: 'scitt')
      first_course = create(:course, provider: scitt_provider, subjects: [drama])
      first_course_option = create(:course_option, course: first_course)

      create(:application_choice, :with_declined_offer, course_option: first_course_option, application_form: first_application_form)

      second_application_form = create(:completed_application_form)
      create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: second_application_form)
      lead_school_provider = create(:provider, provider_type: 'lead_school')
      second_course = create(:course, provider: lead_school_provider, subjects: [drama])
      second_course_option = create(:course_option, course: second_course)

      create(:application_choice, :with_declined_offer, course_option: second_course_option, application_form: second_application_form)

      data = described_class.new.call

      expect(data).to include(
        {
          subject: :drama,
          route: 'scitt',
          degree_class: 'Upper second-class honours (2:1)',
          applications: 1,
          offers_received: 0,
          number_of_acceptances: 0,
          number_of_declined_applications: 1,
          number_of_rejected_applications: 0,
          number_of_withdrawn_applications: 0,
        },
        {
          subject: :drama,
          route: 'lead_school',
          degree_class: 'Upper second-class honours (2:1)',
          applications: 1,
          offers_received: 0,
          number_of_acceptances: 0,
          number_of_declined_applications: 1,
          number_of_rejected_applications: 0,
          number_of_withdrawn_applications: 0,
        },
      )
    end

    context 'when the candidate has an apply again application' do
      it 'only includes the latest apply again application' do
        candidate = create(:candidate)
        provider = create(:provider, provider_type: 'scitt')

        first_course = create(:course, provider: provider, subjects: [create(:subject, code: 'Q8')])
        first_course_option = create(:course_option, course: first_course)

        second_course = create(:course, provider: provider, subjects: [create(:subject, code: 'P1')])
        second_course_option = create(:course_option, course: second_course)

        third_course = create(:course, provider: provider, subjects: [create(:subject, code: '12')])
        third_course_option = create(:course_option, course: third_course)

        first_application_choice = create(:application_choice, :with_declined_offer, course_option: first_course_option, candidate: candidate)
        second_application_choice = create(:application_choice, :with_conditions_not_met, course_option: second_course_option, candidate: candidate)
        third_application_choice = create(:application_choice, :with_withdrawn_offer, course_option: third_course_option, candidate: candidate)

        first_apply_2_course = create(:course, provider: provider, subjects: [create(:subject, code: 'DT')])
        first_apply_2_course_option = create(:course_option, course: first_apply_2_course)
        first_apply_2_application_choice = create(:application_choice, :with_declined_offer, course_option: first_apply_2_course_option, candidate: candidate)

        latest_course = create(:course, provider: provider, subjects: [create(:subject, code: 'W3')])
        latest_course_option = create(:course_option, course: latest_course)
        latest_application_choice = create(:application_choice, :with_accepted_offer, course_option: latest_course_option, candidate: candidate)

        first_application = create(:completed_application_form, candidate: candidate, phase: 'apply_1', application_choices: [first_application_choice, second_application_choice, third_application_choice])
        first_apply_2_application = create(:completed_application_form, candidate: candidate, phase: 'apply_2', application_choices: [first_apply_2_application_choice])
        latest_application = create(:completed_application_form, candidate: candidate, phase: 'apply_2', application_choices: [latest_application_choice])

        create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: first_application)
        create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: first_apply_2_application)
        create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: latest_application)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :classics,
            route: 'scitt',
            degree_class: 'Upper second-class honours (2:1)',
            applications: 1,
            offers_received: 0,
            number_of_acceptances: 0,
            number_of_declined_applications: 1,
            number_of_rejected_applications: 0,
            number_of_withdrawn_applications: 0,
          },
          {
            subject: :other,
            route: 'scitt',
            degree_class: 'Upper second-class honours (2:1)',
            applications: 1,
            offers_received: 1,
            number_of_acceptances: 0,
            number_of_declined_applications: 0,
            number_of_rejected_applications: 0,
            number_of_withdrawn_applications: 0,
          },
          {
            subject: :physical_education,
            route: 'scitt',
            degree_class: 'Upper second-class honours (2:1)',
            applications: 1,
            offers_received: 0,
            number_of_acceptances: 0,
            number_of_declined_applications: 0,
            number_of_rejected_applications: 0,
            number_of_withdrawn_applications: 1,
          },
        )

        expect(data).to include(
          {
            subject: :music,
            route: 'scitt',
            degree_class: 'Upper second-class honours (2:1)',
            applications: 1,
            offers_received: 1,
            number_of_acceptances: 1,
            number_of_declined_applications: 0,
            number_of_rejected_applications: 0,
            number_of_withdrawn_applications: 0,
          },
        )

        expect(data).not_to include(
          {
            subject: :design_and_technology,
            route: 'scitt',
            degree_class: 'Upper second-class honours (2:1)',
            applications: 1,
            offers_received: 0,
            number_of_acceptances: 0,
            number_of_declined_applications: 0,
            number_of_rejected_applications: 0,
            number_of_withdrawn_applications: 1,
          },
        )
      end
    end
  end
end
