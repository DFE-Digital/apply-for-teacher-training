require 'rails_helper'

RSpec.describe InterviewValidations do
  subject(:interview_validations) { described_class.new(interview: interview) }

  let(:interview) { application_choice.interviews.first }
  let(:application_choice) { create(:application_choice, :with_scheduled_interview, course_option: course_option) }
  let(:course) { create(:course, :with_accredited_provider) }
  let(:provider) { course.provider }
  let(:course_option) { create(:course_option, course: course) }

  context 'no changes' do
    let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

    it 'is valid even if date_and_time in the past' do
      expect(interview_validations).to be_valid
    end
  end

  context 'date_and_time updates' do
    context 'changes from future to past' do
      it 'is not valid' do
        interview.date_and_time = 5.days.ago

        expect(interview_validations).not_to be_valid
      end
    end

    context 'changes from past to future' do
      let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

      it 'is not valid' do
        interview.date_and_time = 2.days.from_now

        expect(interview_validations).not_to be_valid
      end
    end

    context 'changes from past to past' do
      let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

      it 'is not valid' do
        interview.date_and_time -= 1.day

        expect(interview_validations).not_to be_valid
      end
    end

    context 'changes from future to future' do
      it 'is valid' do
        interview.date_and_time += 1.day

        expect(interview_validations).to be_valid
      end
    end

    context 'changes from future to after RBD date' do
      it 'is not valid' do
        rbd_date = application_choice.reject_by_default_at
        interview.date_and_time = rbd_date + 1.second

        expect(interview_validations).not_to be_valid
      end
    end
  end

  context 'any change to an interview that has passed' do
    let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

    it 'is not valid' do
      interview.additional_details = 'Changed value'

      expect(interview_validations).not_to be_valid
    end
  end
end
