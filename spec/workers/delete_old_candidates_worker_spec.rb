require 'rails_helper'

RSpec.describe DeleteOldCandidatesWorker do # rubocop:disable RSpec/MultipleDescribes
  before do
    allow(DeleteCandidatesWorker).to receive(:perform_later)
  end

  describe '#perform' do
    it 'enqueus job to delete old candidate' do
      candidate = create(:candidate, last_signed_in_at: 8.years.ago)

      described_class.new.perform
      expect(
        DeleteCandidatesWorker,
      ).to have_received(:perform_later).with([candidate.id])
    end
  end
end

RSpec.describe DeleteCandidatesWorker do
  describe '#perform' do
    let!(:candidate) {
      create(
        :candidate,
        :with_live_session,
        :account_recovery_request,
        :with_posssible_teacher_training,
        last_signed_in_at: 8.years.ago,
      )
    }
    let!(:session_error) { create(:session_error, candidate:) }
    let!(:account_recovery_request_code) {
      create(
        :account_recovery_request_code,
        account_recovery_request: candidate.account_recovery_request,
      )
    }
    let(:expected_records_deleted) {
      [
        Session,
        OneLoginAuth,
        ApplicationChoice,
        ApplicationQualification,
        ApplicationReference,
        ApplicationExperience,
        ApplicationWorkHistoryBreak,
        ApplicationVolunteeringExperience,
        AccountRecoveryRequest,
        PossiblePreviousTeacherTraining,
        PreviousTeacherTraining,
        Pool::Invite,
        CandidatePoolApplication,
        Email,
        EmailClick,
        EnglishProficiency,
        Offer,
        OfferCondition,
        Interview,
        WithdrawalReason,
        Note,
        CandidatePreference,
        CandidateLocationPreference,
        DeferredOfferConfirmation,
        SessionError,
        Notification,
        Adviser::SignUpRequest,
        PoolEligibleApplicationForm,
        ChaserSent,
        ProviderPoolAction,
        ReferenceToken,
        Pool::InviteDeclineReason,
        AccountRecoveryRequestCode,
      ]
    }
    let!(:application_form) {
      create(
        :application_form,
        :with_degree_and_gcses,
        :with_completed_references,
        :with_accepted_offer,
        :with_pool_invite,
        :carry_over,
        :in_candidate_pool,
        :with_emails,
        :with_english_proficiency,
        :with_candidate_preference,
        full_work_history: true,
        volunteering_experiences_count: 1,
        work_experiences_count: 1,
        references_count: 1,
        previous_teacher_training_started: 1,
        candidate:,
      )
    }
    let!(:adviser_sign_up_request) { create(:adviser_sign_up_request, application_form:) }
    let!(:pool_eligible_application_form) { create(:pool_eligible_application_form, application_form:) }
    let!(:chaser_sent) { create(:chaser_sent, chased: application_form) }
    let!(:provider_pool_action) { create(:provider_pool_action, application_form:) }
    let!(:notification) { create(:notification, notified: application_form) }
    let!(:reference_token) {
      create(
        :reference_token,
        application_reference: application_form.application_references.first,
      )
    }
    let!(:pool_invite_decline_reason) {
      create(
        :pool_invite_decline_reason,
        invite: application_form.published_invites.first,
      )
    }
    let!(:offered_choice) {
      create(
        :application_choice,
        :offered,
        application_form:,
      )
    }
    let!(:deffered_offer) {
      create(:deferred_offer_confirmation, offer: offered_choice.offer, provider_user: create(:provider_user, create_notification_preference: false))
    }
    let!(:interview_choice) {
      create(
        :application_choice,
        :interviewing,
        application_form:,
      )
    }
    let!(:withdrawn_choice) {
      create(
        :application_choice,
        :with_withdrawal_reason,
        :with_note,
        application_form:,
      )
    }

    it 'deletes old candidates and their associated records' do
      candidate_id = candidate.id
      application_form_ids = candidate.application_forms.ids.sort
      application_choice_ids = candidate.application_choices.ids.sort
      expected_records_deleted.each do |model|
        raise "#{model} not created" if model.none?

        expect(model.count).not_to eq(0)
      end
      expect(ApplicationForm.count).to eq(2)

      expect { described_class.new.perform([candidate]) }.to change { Candidate.count }.by(-1)
      expect { candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_form.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expected_records_deleted.each do |model|
        expect(model.count).to eq(0)
      end
      expect(ApplicationForm.count).to eq(0)
      expect(DeletedCandidate.first.candidate_id).to eq(candidate_id)
      expect(DeletedCandidate.first.deleted_records['candidates']).to eq([candidate_id])
      expect(DeletedCandidate.first.deleted_records['application_forms'].sort).to eq(application_form_ids)
      expect(DeletedCandidate.first.deleted_records['application_choices'].sort).to eq(application_choice_ids)
      # return only analytics records
      expect(DeletedCandidate.first.deleted_records['sessions']).to be_nil

      expected_deleted_records = %w[previous_teacher_trainings candidate_preferences
                                    candidate_location_preferences candidates pool_invites
                                    one_login_auths account_recovery_requests application_choices
                                    application_experiences application_work_history_breaks
                                    application_forms application_qualifications
                                    email_clicks english_proficiencies
                                    interviews notes offer_conditions offers references withdrawal_reasons
                                    adviser_sign_up_requests pool_eligible_application_forms chasers_sent
                                    reference_tokens pool_invite_decline_reasons account_recovery_request_codes]

      expected_deleted_records.each do |key|
        raise "Key #{key} not in expected_deleted_records" if DeletedCandidate.first.deleted_records.keys.exclude?(key)

        expect(DeletedCandidate.first.deleted_records.keys.include?(key)).to be(true)
      end
    end
  end
end
