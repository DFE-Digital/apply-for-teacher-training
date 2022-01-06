require 'rails_helper'

RSpec.describe SupportInterface::MinisterialReportApplicationsExport do
  include MonthlyStatisticsTestHelper

  describe '#call' do
    let(:statistics) do
      generate_monthly_statistics_test_data

      { rows: described_class.new.call }
    end

    it 'returns the correct data' do
      expect_report_rows(column_headings: %i[
        subject
        applications
        offer_received
        accepted
        application_declined
        application_rejected
        application_withdrawn
      ]) do
        [[:art_and_design,           0, 0, 0, 0, 0, 0],
         [:biology,                  0, 0, 0, 0, 0, 0],
         [:business_studies,         0, 0, 0, 0, 0, 0],
         [:chemistry,                0, 0, 0, 0, 0, 0],
         [:classics,                 0, 0, 0, 0, 0, 0],
         [:computing,                0, 0, 0, 0, 0, 0],
         [:design_and_technology,    0, 0, 0, 0, 0, 0],
         [:drama,                    0, 0, 0, 0, 0, 0],
         [:english,                  0, 0, 0, 0, 0, 0],
         [:geography,                0, 0, 0, 0, 0, 0],
         [:history,                  1, 0, 0, 1, 0, 0],
         [:mathematics,              0, 0, 0, 0, 0, 0],
         [:modern_foreign_languages, 0, 0, 0, 0, 0, 0],
         [:music,                    0, 0, 0, 0, 0, 0],
         [:other,                    0, 0, 0, 0, 0, 0],
         [:physical_education,       0, 0, 0, 0, 0, 0],
         [:physics,                  0, 0, 0, 0, 0, 0],
         [:religious_education,      0, 0, 0, 0, 0, 0],
         [:stem,                     0, 0, 0, 0, 0, 0],
         [:ebacc,                    1, 0, 0, 1, 0, 0],
         [:primary,                  8, 4, 3, 0, 0, 0],
         [:secondary,                5, 2, 2, 1, 1, 1],
         [:total,                    13, 6, 5, 1, 1, 1]]
      end
    end

    context 'when the candidate has an apply again application' do
      it 'only includes the latest apply again application' do
        candidate = create(:candidate)

        first_course = create(:course, subjects: [create(:subject, code: '41')])
        first_course_option = create(:course_option, course: first_course)

        second_course = create(:course, subjects: [create(:subject, code: 'P1')])
        second_course_option = create(:course_option, course: second_course)

        third_course = create(:course, subjects: [create(:subject, code: '12')])
        third_course_option = create(:course_option, course: third_course)

        first_application_choice = create(:application_choice, :with_declined_offer, course_option: first_course_option, candidate: candidate)
        second_application_choice = create(:application_choice, :with_conditions_not_met, course_option: second_course_option, candidate: candidate)
        third_application_choice = create(:application_choice, :with_withdrawn_offer, course_option: third_course_option, candidate: candidate)

        first_apply_2_course = create(:course, subjects: [create(:subject, code: 'DT')])
        first_apply_2_course_option = create(:course_option, course: first_apply_2_course)
        first_apply_2_application_choice = create(:application_choice, :with_declined_offer, course_option: first_apply_2_course_option, candidate: candidate)

        latest_course = create(:course, subjects: [create(:subject, code: 'C6')])
        latest_course_option = create(:course_option, course: latest_course)
        latest_application_choice = create(:application_choice, :with_accepted_offer, course_option: latest_course_option, candidate: candidate)

        create(:completed_application_form, candidate: candidate, phase: 'apply_1', application_choices: [first_application_choice, second_application_choice, third_application_choice])
        create(:completed_application_form, candidate: candidate, phase: 'apply_2', application_choices: [first_apply_2_application_choice])
        create(:completed_application_form, candidate: candidate, phase: 'apply_2', application_choices: [latest_application_choice])

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :total,
            applications: 4,
            offer_received: 2,
            accepted: 1,
            application_declined: 1,
            application_rejected: 0,
            application_withdrawn: 1,
          },
        )

        expect(data).not_to include(
          {
            subject: :design_and_technology,
            applications: 1,
            offer_received: 0,
            accepted: 0,
            application_declined: 1,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the application has a course choice with two associated subjects' do
      it 'returns the first subject as the dominant choice when the course name is a single word' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Physics with Mathematics', subjects: [create(:subject, name: 'Mathematics', code: 'G1'), create(:subject, name: 'Physics', code: 'F3')])
        course_option = create(:course_option, course: course)
        create(:application_choice, :with_accepted_offer, course_option: course_option, application_form: application_form)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :physics,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).not_to include(
          {
            subject: :mathematics,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end

      it 'returns the first subject as the dominant choice when the course name contains two words' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Business studies with History', subjects: [create(:subject, name: 'Business studies', code: '08'), create(:subject, name: 'History', code: 'V1')])
        course_option = create(:course_option, course: course)
        create(:application_choice, :with_accepted_offer, course_option: course_option, application_form: application_form)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :business_studies,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).not_to include(
          {
            subject: :history,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end

      it 'returns the first subject as the dominant choice when the associated subjects are in brackets' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Modern Langauges (French with Spanish)', subjects: [create(:subject, name: 'Spanish', code: '22'), create(:subject, name: 'French', code: '15')])
        course_option = create(:course_option, course: course)
        create(:application_choice, :with_accepted_offer, course_option: course_option, application_form: application_form)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :modern_foreign_languages,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end

      it 'takes the first subject in the array when it cannot find the dominant subject' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Nonsense course', level: 'secondary', subjects: [create(:subject, name: 'Business studies', code: '08'), create(:subject, name: 'History', code: 'V1')])
        course_option = create(:course_option, course: course)
        create(:application_choice, :with_accepted_offer, course_option: course_option, application_form: application_form)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :business_studies,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        ).or include(
          {
            subject: :history,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end

      it 'can match a physical education subject when the course is titled PE' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'PE with EBacc', level: 'secondary', subjects: [create(:subject, name: 'Biology', code: 'C1'), create(:subject, name: 'Physical education', code: 'C6')])
        course_option = create(:course_option, course: course)
        create(:application_choice, :with_accepted_offer, course_option: course_option, application_form: application_form)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :physical_education,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).not_to include(
          {
            subject: :biology,
            applications: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end
  end
end
