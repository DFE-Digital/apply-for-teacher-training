require 'rails_helper'

RSpec.describe SupportInterface::MinisterialReportCandidatesExport do
  include StatisticsTestHelper

  before { stub_const('CourseChoice', Struct.new(:name, :subjects, :status)) }

  describe '#call' do
    let(:statistics) do
      generate_statistics_test_data

      { rows: described_class.new.call }
    end

    it 'returns the correct data' do
      expect_report_rows(column_headings: %i[
        subject
        candidates
        offer_received
        accepted
        application_declined
        application_rejected
        application_withdrawn
      ]) do
        [[:art_and_design,           1, 1, 0, 1, 0, 0],
         [:biology,                  3, 1, 1, 0, 1, 1],
         [:business_studies,         1, 1, 1, 0, 0, 0],
         [:chemistry,                1, 0, 0, 0, 1, 0],
         [:classics,                 0, 0, 0, 0, 0, 0],
         [:computing,                0, 0, 0, 0, 0, 0],
         [:design_and_technology,    0, 0, 0, 0, 0, 0],
         [:drama,                    2, 0, 0, 0, 2, 0],
         [:english,                  1, 0, 0, 0, 0, 1],
         [:further_education,        1, 0, 0, 0, 1, 0],
         [:geography,                0, 0, 0, 0, 0, 0],
         [:history,                  0, 0, 0, 0, 0, 0],
         [:mathematics,              1, 0, 0, 0, 1, 0],
         [:modern_foreign_languages, 2, 1, 1, 0, 1, 0],
         [:music,                    0, 0, 0, 0, 0, 0],
         [:other,                    2, 1, 1, 0, 0, 1],
         [:physical_education,       0, 0, 0, 0, 0, 0],
         [:physics,                  1, 0, 0, 0, 0, 1],
         [:religious_education,      0, 0, 0, 0, 0, 0],
         [:stem,                     6, 1, 1, 0, 3, 2],
         [:ebacc,                    9, 2, 2, 0, 4, 3],
         [:primary,                  4, 3, 2, 0, 0, 0],
         [:secondary,                15, 5, 4, 1, 6, 4],
         [:split,                    1, 1, 1, 0, 0, 0],
         [:total,                    20, 9, 7, 1, 6, 4]]
      end
    end

    context 'when the two subject choices are different' do
      it 'splits the candidate' do
        create_application(
          CourseChoice.new('Primary', '06', :accepted),
          CourseChoice.new('Magical studies', 'C8', :declined),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :split,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :primary,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the three subject choices are different' do
      it 'splits the candidate' do
        create_application(
          CourseChoice.new('Fizziks', 'F0', :accepted),
          CourseChoice.new('Computering', '11', :declined),
          CourseChoice.new('Acting and singing', '13', :offer_withdrawn),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :split,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has a single dominant subject' do
      it 'correctly allocates the candidate' do
        create_application(
          CourseChoice.new('Drama', '13', :declined),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :drama,
            candidates: 1,
            offer_received: 1,
            accepted: 0,
            application_declined: 1,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has two matching subject choices' do
      it 'correctly allocates the candidate' do
        create_application(
          CourseChoice.new('Business', '08', :accepted),
          CourseChoice.new('Business studies', 'L1', :declined),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :business_studies,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has three choices with two matching subjects' do
      it 'correctly allocates the candidate' do
        create_application(
          CourseChoice.new('Special relativity', 'F0', :accepted),
          CourseChoice.new('Laws of the universe', 'F3', :declined),
          CourseChoice.new('Theology', 'V6', :offer_withdrawn),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :physics,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :religious_education,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :split,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has four choices with two pairs of subjects' do
      it 'correctly allocates the candidate' do
        create_application(
          CourseChoice.new('Physics', 'F0', :accepted),
          CourseChoice.new('Physics', 'F3', :declined),
          CourseChoice.new('Business', '08', :offer_withdrawn),
          CourseChoice.new('Business', 'L1', :declined),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :split,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :physics,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :business_studies,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has two choices with 2 pairs of matching subjects' do
      it 'correctly allocates the candidate' do
        create_application(
          CourseChoice.new('Thermodynamics', %w[F0 08], :accepted),
          CourseChoice.new('General relativity', %w[F3 L1], :declined),
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :physics,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has a course choice with two associated subjects' do
      it 'returns the first subject as the dominant choice when the course name is a single words' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Physics with Mathematics', subjects: [create(:subject, name: 'Mathematics', code: 'G1'), create(:subject, name: 'Physics', code: 'F3')])
        course_option = create(:course_option, course:)
        create(:application_choice, :accepted, course_option:, application_form:)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :physics,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :mathematics,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end

      it 'returns the first subject as the dominant choice when the course name contains two words' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Business studies with History', subjects: [create(:subject, name: 'Business studies', code: '08'), create(:subject, name: 'History', code: 'V1')])
        course_option = create(:course_option, course:)
        create(:application_choice, :accepted, course_option:, application_form:)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :business_studies,
            candidates: 1,
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
        course_option = create(:course_option, course:)
        create(:application_choice, :accepted, course_option:, application_form:)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :modern_foreign_languages,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end

      it 'defaults the subject to a subtotal when it cannot find the dominant subject' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Nonsense course', level: 'secondary', subjects: [create(:subject, name: 'Business studies', code: '08'), create(:subject, name: 'History', code: 'V1')])
        course_option = create(:course_option, course:)
        create(:application_choice, :accepted, course_option:, application_form:)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :secondary,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has an apply again application' do
      it 'only includes the latest apply again application and the dominant subject from their first application' do
        candidate = create(:candidate)

        first_course = create(:course, subjects: [create(:subject, code: 'F0')])
        first_course_option = create(:course_option, course: first_course)

        second_course = create(:course, subjects: [create(:subject, code: 'F3')])
        second_course_option = create(:course_option, course: second_course)

        third_course = create(:course, subjects: [create(:subject, code: '15')])
        third_course_option = create(:course_option, course: third_course)

        first_application_choice = create(:application_choice, :declined, course_option: first_course_option, candidate:)
        second_application_choice = create(:application_choice, :offer_withdrawn, course_option: second_course_option, candidate:)
        third_application_choice = create(:application_choice, :offer_withdrawn, course_option: third_course_option, candidate:)

        first_apply_2_course = create(:course, subjects: [create(:subject, code: '16')])
        first_apply_2_course_option = create(:course_option, course: first_apply_2_course)
        first_apply_2_application_choice = create(:application_choice, :declined, course_option: first_apply_2_course_option, candidate:)

        latest_course = create(:course, subjects: [create(:subject, code: '17')])
        latest_course_option = create(:course_option, course: latest_course)
        latest_application_choice = create(:application_choice, :accepted, course_option: latest_course_option, candidate:)

        create(:completed_application_form, candidate:, phase: 'apply_1', application_choices: [first_application_choice, second_application_choice, third_application_choice])
        create(:completed_application_form, candidate:, phase: 'apply_2', application_choices: [first_apply_2_application_choice])
        create(:completed_application_form, candidate:, phase: 'apply_2', application_choices: [latest_application_choice])

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :total,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :physics,
            candidates: 1,
            offer_received: 1,
            accepted: 1,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :modern_foreign_languages,
            candidates: 0,
            offer_received: 0,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end

    context 'when the candidate has an apply again application carried over from previous cycle' do
      around do |example|
        ApplicationForm.with_unsafe_application_choice_touches do
          example.run
        end
      end

      it 'includes the apply again application carried over from the previous cycle' do
        candidate = create(:candidate)

        course = create(:course, subjects: [create(:subject, code: 'F0')])
        course_option = create(:course_option, course:)

        application_choice = create(
          :application_choice,
          :offered,
          course_option:,
          candidate:,
          current_recruitment_cycle_year: current_year,
        )

        create(
          :completed_application_form,
          candidate:,
          phase: 'apply_2',
          application_choices: [application_choice],
          recruitment_cycle_year: previous_year,
        )

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :total,
            candidates: 1,
            offer_received: 1,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )

        expect(data).to include(
          {
            subject: :physics,
            candidates: 1,
            offer_received: 1,
            accepted: 0,
            application_declined: 0,
            application_rejected: 0,
            application_withdrawn: 0,
          },
        )
      end
    end
  end

  describe '#determine_states' do
    context 'when the status is successful' do
      it 'returns the offer and accepted mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :accepted, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates offer_received accepted])
      end
    end

    context 'when the status is conditions not met' do
      it 'returns the offer mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :conditions_not_met, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates application_rejected])
      end
    end

    context 'when the status is awaiting_provider_decision' do
      it 'returns just the candidates mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :awaiting_provider_decision, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates])
      end
    end

    context 'when the status is offer_withdrawn' do
      it 'returns just the candidates mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :offer_withdrawn, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates])
      end
    end

    context 'when the status is declined' do
      it 'returns the declined mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :declined, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates offer_received application_declined])
      end
    end

    context 'when the status is rejected' do
      it 'returns the rejected mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :rejected, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates application_rejected])
      end
    end

    context 'when the status is withdrawn' do
      it 'returns the withdrawn mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :withdrawn, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates application_withdrawn])
      end
    end

    context 'when there are two choices one withdrawn and one rejected' do
      it 'returns the rejected mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :withdrawn, application_form:)
        create(:application_choice, :rejected, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates application_rejected])
      end
    end

    context 'when there are two choices one declined and one rejected' do
      it 'returns the declined mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :declined, application_form:)
        create(:application_choice, :rejected, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates offer_received application_declined])
      end
    end

    context 'when there are two choices one awaiting provider decision and one rejected' do
      it 'returns the awaiting provider decision mapping' do
        application_form = create(:completed_application_form)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :rejected, application_form:)

        expect(described_class.new.determine_states([application_form])).to match_array(%i[candidates])
      end
    end
  end

  def create_application(*course_choices)
    application_form = create(:completed_application_form)

    course_choices.each do |course_choice|
      course = create(
        :course,
        name: course_choice.name,
        subjects: subjects_for(course_choice.subjects),
      )
      course_option = create(:course_option, course:)
      create(
        :application_choice,
        course_choice.status,
        course_option:,
        application_form:,
      )
    end
  end

  def subjects_for(subject_code_or_codes)
    if subject_code_or_codes.is_a?(Array)
      subject_code_or_codes.map { |subject_code| create(:subject, name: MinisterialReport::SUBJECT_CODE_MAPPINGS[subject_code].to_s, code: subject_code) }
    else
      [create(:subject, name: MinisterialReport::SUBJECT_CODE_MAPPINGS[subject_code_or_codes].to_s, code: subject_code_or_codes)]
    end
  end
end
