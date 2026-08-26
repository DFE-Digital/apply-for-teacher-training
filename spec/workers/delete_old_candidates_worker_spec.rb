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
    let(:expected_records_deleted) {
      [
        Session,
        OneLoginAuth,
        ApplicationChoice,
        ApplicationQualification,
        ApplicationReference,
        ApplicationExperience,
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
    let!(:offered_choice) {
      create(
        :application_choice,
        :offered,
        application_form:,
      )
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
    end
  end
end
