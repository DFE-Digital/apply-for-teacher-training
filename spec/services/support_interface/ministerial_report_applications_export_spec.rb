require 'rails_helper'

RSpec.describe SupportInterface::MinisterialReportApplicationsExport do
  describe '#call' do
    it 'generates the full report with the correct totals' do
      test_subject = described_class.new

      allow(test_subject).to receive(:subject_status_count).and_return(
        { ['00', 'offer_withdrawn', 1003, 'Primary (3-7)'] => 1,
          ['00', 'withdrawn', 1010, 'Primary (3-7)'] => 1,
          ['00', 'awaiting_provider_decision', 1022, 'Primary (with Art and Design)'] => 1,
          ['00', 'offer', 1038, 'Primary (3-7)'] => 1,
          ['00', 'offer_withdrawn', 1049, 'Primary (3-7)'] => 1,
          ['01', 'rejected', 1001, 'Primary (with English)'] => 1,
          ['01', 'declined', 1006, 'Primary (with English)'] => 1,
          ['01', 'awaiting_provider_decision', 1016, 'Primary (with English)'] => 1,
          ['01', 'awaiting_provider_decision', 1021, 'Primary (with English)'] => 1,
          ['01', 'recruited', 1055, 'Primary (with English)'] => 1,
          ['02', 'offer_deferred', 1004, 'Primary (Geography and History with SEN)'] => 1,
          ['02', 'rejected', 1044, 'Primary (with Geography and History)'] => 1,
          ['02', 'rejected', 1048, 'Primary (with Geography and History)'] => 1,
          ['02', 'declined', 1052, 'Primary (with Geography and History)'] => 1,
          ['03', 'conditions_not_met', 1009, 'Primary with Mathematics (Special Education Needs)'] => 1,
          ['03', 'offer', 1027, 'Primary (with Mathematics)'] => 1,
          ['03', 'rejected', 1032, 'Primary with Mathematics'] => 1,
          ['03', 'awaiting_provider_decision', 1035, 'Primary (with Mathematics)'] => 1,
          ['03', 'offer', 1039, 'Primary (with Mathematics)'] => 1,
          ['03', 'recruited', 1054, 'Primary (with Mathematics)'] => 1,
          ['06', 'awaiting_provider_decision', 1017, 'Primary (with Physical Education)'] => 1,
          ['06', 'awaiting_provider_decision', 1023, 'Primary (with Physical Education)'] => 1,
          ['06', 'rejected', 1030, 'Primary (with Physical Education)'] => 1,
          ['06', 'awaiting_provider_decision', 1031, 'Primary (with Physical Education)'] => 1,
          ['07', 'interviewing', 1025, 'Primary (with Science)'] => 1,
          ['07', 'interviewing', 1029, 'Primary (with Science)'] => 1,
          ['07', 'rejected', 1045, 'Primary (with Science)'] => 1,
          ['07', 'offer', 1046, 'Primary (with Science)'] => 1,
          ['11', 'rejected', 1040, 'Computing'] => 1,
          ['11', 'offer_deferred', 1051, 'Computing'] => 1,
          ['11', 'withdrawn', 1057, 'Computing'] => 1,
          ['13', 'awaiting_provider_decision', 1019, 'Drama'] => 1,
          ['22', 'awaiting_provider_decision', 1011, 'Modern Languages (Spanish)'] => 1,
          ['24', 'offer', 1037, 'Modern Languages'] => 1,
          ['C6', 'recruited', 1008, 'Physical Education'] => 1,
          ['C6', 'awaiting_provider_decision', 1026, 'Physical Education'] => 1,
          ['C6', 'declined', 1034, 'Physical Education (Special Educational Needs)'] => 1,
          ['C6', 'offer', 1036, 'Physical Education'] => 1,
          ['DT', 'rejected', 1002, 'Design and Technology'] => 1,
          ['DT', 'awaiting_provider_decision', 1018, 'Design and Technology'] => 1,
          ['DT', 'pending_conditions', 1053, 'Design and Technology'] => 1,
          ['F1', 'offer_deferred', 1005, 'Chemistry'] => 1,
          ['F1', 'declined', 1041, 'Chemistry'] => 1,
          ['F1', 'offer_deferred', 1050, 'Chemistry'] => 1,
          ['F3', 'cancelled', 19630, 'Physics with Mathematics'] => 1,
          ['F8', 'pending_conditions', 1007, 'Geography'] => 1,
          ['F8', 'awaiting_provider_decision', 1020, 'Geography'] => 1,
          ['F8', 'rejected', 1042, 'Geography'] => 1,
          ['F8', 'offer', 1043, 'Geography'] => 1,
          ['G1', 'rejected', 1047, 'Mathematics'] => 1,
          ['G1', 'cancelled', 19630, 'Physics with Mathematics'] => 1,
          ['Q3', 'awaiting_provider_decision', 1024, 'English'] => 1,
          ['V6', 'conditions_not_met', 1056, 'Religious Education'] => 1,
          ['W1', 'declined', 1033, 'Art and Design'] => 1,
          ['W3', 'interviewing', 1028, 'Music'] => 1 },
      )

      data = test_subject.call

      expect(data).to contain_exactly(
        {
          subject: :art_and_design,
          applications: 1,
          offer_received: 0,
          accepted: 0,
          application_declined: 1,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :biology,
          applications: 0,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :business_studies,
          applications: 0,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :chemistry,
          applications: 3,
          offer_received: 2,
          accepted: 2,
          application_declined: 1,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :classics,
          applications: 0,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :computing,
          applications: 3,
          offer_received: 1,
          accepted: 1,
          application_declined: 0,
          application_rejected: 1,
          application_withdrawn: 1,
        },
        {
          subject: :design_and_technology,
          applications: 3,
          offer_received: 1,
          accepted: 1,
          application_declined: 0,
          application_rejected: 1,
          application_withdrawn: 0,
        },
        {
          subject: :drama,
          applications: 1,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :english,
          applications: 1,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :geography,
          applications: 4,
          offer_received: 2,
          accepted: 1,
          application_declined: 0,
          application_rejected: 1,
          application_withdrawn: 0,
        },
        {
          subject: :history,
          applications: 0,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :mathematics,
          applications: 1,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 1,
          application_withdrawn: 0,
        },
        {
          subject: :modern_foreign_languages,
          applications: 2,
          offer_received: 1,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :music,
          applications: 1,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :other,
          applications: 0,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :physical_education,
          applications: 4,
          offer_received: 2,
          accepted: 1,
          application_declined: 1,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :physics,
          applications: 1,
          offer_received: 0,
          accepted: 0,
          application_declined: 1,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :religious_education,
          applications: 1,
          offer_received: 1,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        },
        {
          subject: :stem,
          applications: 8,
          offer_received: 3,
          accepted: 3,
          application_declined: 2,
          application_rejected: 2,
          application_withdrawn: 1,
        },
        {
          subject: :ebacc,
          applications: 15,
          offer_received: 6,
          accepted: 4,
          application_declined: 2,
          application_rejected: 3,
          application_withdrawn: 1,
        },
        {
          subject: :primary,
          applications: 28,
          offer_received: 8,
          accepted: 3,
          application_declined: 2,
          application_rejected: 6,
          application_withdrawn: 3,
        },
        {
          subject: :secondary,
          applications: 26,
          offer_received: 10,
          accepted: 6,
          application_declined: 4,
          application_rejected: 4,
          application_withdrawn: 1,
        },
        {
          subject: :total,
          applications: 54,
          offer_received: 18,
          accepted: 9,
          application_declined: 6,
          application_rejected: 10,
          application_withdrawn: 4,
        },
      )
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

      it 'defaults the subject to a subtotal when it cannot find the dominant subject' do
        application_form = create(:completed_application_form)
        course = create(:course, name: 'Nonsense course', level: 'secondary', subjects: [create(:subject, name: 'Business studies', code: '08'), create(:subject, name: 'History', code: 'V1')])
        course_option = create(:course_option, course: course)
        create(:application_choice, :with_accepted_offer, course_option: course_option, application_form: application_form)

        data = described_class.new.call

        expect(data).to include(
          {
            subject: :secondary,
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
    end
  end
end
