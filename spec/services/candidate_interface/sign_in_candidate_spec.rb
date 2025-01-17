require 'rails_helper'

RSpec.describe CandidateInterface::SignInCandidate do
  let(:controller_double) do
    instance_double(
      CandidateInterface::SignInController,
      params: {},
      set_user_context: true,
      candidate_interface_check_email_sign_in_path: true,
      redirect_to: true,
      track_validation_error: true,
      render: true,
    )
  end

  it 'renders the sign - in page again with errors when the email address is invalid' do
    email = 'not-an-email-address'

    described_class.new(email, controller_double).call

    expect(controller_double).to have_received(:track_validation_error).with(kind_of(Candidate))
    expect(controller_double).to have_received(:render).with('candidate_interface/sign_in/new', locals: { candidate: kind_of(Candidate) })
  end

  it "sends an email to the address when there's no matching Candidate" do
    allow(AuthenticationMailer).to receive(:sign_in_without_account_email).and_call_original
    email = 'someone@email.address'

    described_class.new(email, controller_double).call

    expect(AuthenticationMailer).to have_received(:sign_in_without_account_email).with(to: email)
  end

  it 'sends a magic link to the candidate' do
    allow(CandidateInterface::RequestMagicLink).to receive(:for_sign_in).and_call_original
    email = 'candidate@email.address'
    candidate = create(:candidate, email_address: email)

    described_class.new(email, controller_double).call

    expect(CandidateInterface::RequestMagicLink).to have_received(:for_sign_in).with(candidate: candidate)
  end

  context 'when Candidate email address is used but the Candidate is connected to a OneLoginAuth with a different email address' do
    # Candidate has used the Account Recovery feature to sign in with a different email address
    # Their old email address should not be used to sign in

    it 'renders the sign-in page again with errors when the old email address is used' do
      candidate = create(:candidate, email_address: 'candidate@email.address')
      _one_login_auth = create(:one_login_auth, email_address: 'one_login@email.address', candidate: candidate)

      described_class.new('candidate@email.address', controller_double).call

      expect(controller_double).to have_received(:track_validation_error).with(kind_of(Candidate))
      expect(controller_double).to have_received(:render).with('candidate_interface/sign_in/new', locals: { candidate: kind_of(Candidate) })
    end

    it 'sends a magic link to the candidate when the new email address is used' do
      allow(CandidateInterface::RequestMagicLink).to receive(:for_sign_in).and_call_original
      candidate = create(:candidate, email_address: 'candidate@email.address')
      _one_login_auth = create(:one_login_auth, email_address: 'one_login@email.address', candidate: candidate)

      described_class.new('one_login@email.address', controller_double).call

      expect(CandidateInterface::RequestMagicLink).to have_received(:for_sign_in).with(candidate: candidate)
    end
  end

  context 'when Candidate email address is used with a connected to a OneLoginAuth' do
    # Candidate has set up OneLogin with the same email address

    it 'sends a magic link to the candidate' do
      allow(CandidateInterface::RequestMagicLink).to receive(:for_sign_in).and_call_original
      email = 'one_login@email.address'
      candidate = create(:candidate, email_address: email)
      _one_login_auth = create(:one_login_auth, email_address: email, candidate: candidate)

      described_class.new(email, controller_double).call

      expect(CandidateInterface::RequestMagicLink).to have_received(:for_sign_in).with(candidate: candidate)
    end
  end

  context 'Candidate has been redirected from Find' do
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
        create(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year, candidate:)

        described_class.new(candidate.email_address, controller_double).call

        expect(candidate.reload.course_from_find_id).to eq course.id
      end
    end

    context 'course is in the previous cycle' do
      let(:course) { create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year) }

      it 'is does not set the candidates `course_from_find_id` if the course is not in the current cycle' do
        candidate = create(:candidate)
        create(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year, candidate:)

        described_class.new(candidate.email_address, controller_double).call

        expect(candidate.reload.course_from_find_id).to be_nil
      end
    end
  end
end
