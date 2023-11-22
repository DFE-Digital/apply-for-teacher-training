require 'rails_helper'

RSpec.describe InterviewWorkflowConstraints do
  subject(:workflow_constraints) { described_class.new(interview:) }

  let(:interview) { application_choice.interviews.first }
  let(:application_choice) { create(:application_choice, :interviewing, course_option:) }
  let(:course) { create(:course, :with_accredited_provider) }
  let(:provider) { course.provider }
  let(:course_option) { create(:course_option, course:) }

  def message(error)
    I18n.t("activemodel.errors.models.interview_workflow_constraints.attributes.#{error}")
  end

  context 'application in interviewable state' do
    let(:application_choice) { create(:application_choice, :inactive, course_option:) }

    context 'new interview' do
      let(:interview) { build(:interview, application_choice:, skip_application_choice_status_update: true) }

      it 'does not raises InterviewWorkflowError' do
        expect { workflow_constraints.create! }.not_to raise_error(InterviewWorkflowConstraints::WorkflowError)
      end
    end
  end

  context 'application_choice past interviewing stage' do
    let(:application_choice) { create(:application_choice, :offered, course_option:) }

    context 'new interview' do
      let(:interview) { build(:interview, application_choice:, skip_application_choice_status_update: true) }

      it 'raises InterviewWorkflowError' do
        expect { workflow_constraints.create! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_interviews_for_application_not_in_interviewing_states)
      end
    end

    context 'update interview' do
      let(:interview) { create(:interview, application_choice:, skip_application_choice_status_update: true) }

      it 'raises InterviewWorkflowError' do
        interview.additional_details = 'New additional details'

        expect { workflow_constraints.create! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_interviews_for_application_not_in_interviewing_states)
      end
    end

    context 'cancel interview' do
      let(:interview) { create(:interview, application_choice:, skip_application_choice_status_update: true) }

      it 'raises InterviewWorkflowError' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect { workflow_constraints.create! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_interviews_for_application_not_in_interviewing_states)
      end
    end
  end

  context 'update interview' do
    context 'any change to an interview that has passed' do
      let(:interview) { create(:interview, :past_date_and_time, application_choice:) }

      it 'raises InterviewWorkflowError' do
        interview.additional_details = 'Changed value'

        expect { workflow_constraints.update! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_a_past_interview)
      end
    end

    context 'any change to a cancelled interview' do
      let(:interview) { create(:interview, :cancelled, application_choice:) }

      it 'raises InterviewWorkflowError' do
        interview.additional_details = 'Changed value'

        expect { workflow_constraints.update! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_a_cancelled_interview)
      end
    end

    context 'date_and_time' do
      context 'changes from past to future' do
        let(:interview) { create(:interview, :past_date_and_time, application_choice:) }

        it 'raises InterviewWorkflowError' do
          interview.date_and_time = 2.days.from_now

          expect { workflow_constraints.update! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
            .with_message message(:changing_a_past_interview)
        end
      end

      context 'changes from past to past' do
        let(:interview) { create(:interview, :past_date_and_time, application_choice:) }

        it 'raises InterviewWorkflowError' do
          interview.date_and_time -= 1.day

          expect { workflow_constraints.update! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
            .with_message message(:changing_a_past_interview)
        end
      end
    end
  end

  context 'cancel interview' do
    context 'when interview has passed' do
      let(:interview) { create(:interview, :past_date_and_time, application_choice:) }

      it 'raises InterviewWorkflowError' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect { workflow_constraints.cancel! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_a_past_interview)
      end
    end

    context 'when interview is already cancelled' do
      let(:interview) { create(:interview, :cancelled, date_and_time: 5.days.from_now) }

      it 'raises InterviewWorkflowError' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect { workflow_constraints.cancel! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
          .with_message message(:changing_a_cancelled_interview)
      end
    end
  end
end
