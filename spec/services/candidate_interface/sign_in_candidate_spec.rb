require 'rails_helper'

RSpec.describe CandidateInterface::SignInCandidate do
  let(:controller_double) do
    instance_double(
      CandidateInterface::SignInController,
      params: {
        providerCode: course.provider.code,
        courseCode: course.code,
      },
      set_user_context: true,
      candidate_interface_check_email_sign_in_path: true,
      redirect_to: true,
    )
  end

  context 'course is in the current cycle' do
    let(:course) { create(:course, recruitment_cycle_year: RecruitmentCycle.current_year) }

    it 'is sets the candidates `course_from_find_id` to the course.id' do
      candidate = create(:candidate)
      create(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year, candidate: candidate)

      described_class.new(candidate.email_address, controller_double).call

      expect(candidate.reload.course_from_find_id).to eq course.id
    end
  end

  context 'course is in the previous cycle' do
    let(:course) {  create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year) }

    it 'is does not set the candidates `course_from_find_id` if the course is not in the current cycle' do
      candidate = create(:candidate)
      create(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year, candidate: candidate)

      described_class.new(candidate.email_address, controller_double).call

      expect(candidate.reload.course_from_find_id).to eq nil
    end
  end
end
