require 'rails_helper'

RSpec.describe Candidate do
  before do
    TestSuiteTimeMachine.unfreeze!
  end

  describe 'associations' do
    it { is_expected.to have_many(:application_forms) }
    it { is_expected.to have_many(:degree_qualifications).through(:application_forms) }
    it { is_expected.to have_many(:sessions) }
    it { is_expected.to have_many(:session_errors) }
    it { is_expected.to have_many(:pool_dismissals).dependent(:destroy) }
    it { is_expected.to have_many(:pool_invites).dependent(:destroy) }
    it { is_expected.to have_many(:preferences).dependent(:destroy) }
    it { is_expected.to have_many(:published_preferences).conditions(status: 'published').dependent(:destroy) }
    it { is_expected.to have_one(:one_login_auth).dependent(:destroy) }
    it { is_expected.to have_one(:account_recovery_request).dependent(:destroy) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:previous_account_email_address).to(:account_recovery_request).allow_nil }
  end

  describe 'a valid candidate' do
    subject { create(:candidate) }

    it_behaves_like 'an email address valid for notify'

    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
    it { is_expected.not_to allow_value('foo').for(:email_address) }
    it { is_expected.not_to allow_value(Faker::Lorem.characters(number: 251)).for(:email_address) }
  end

  describe 'before_save' do
    context 'with application choices' do
      it 'touches the application choice when a field affecting the application choice is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(email_address: 'new.email@example.com') }
          .to(change { application_form.application_choices.first.updated_at })
      end

      it 'does not touch the application choice when a field not affecting the application choice is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(last_signed_in_at: Time.zone.now) }
          .not_to(change { application_form.application_choices.first.updated_at })
      end

      it 'does not touch the application choice when its in a previous recruitment cycle' do
        candidate = create(:candidate)
        application_choice = create(:application_choice, current_recruitment_cycle_year: previous_year)
        application_form = ApplicationForm.with_unsafe_application_choice_touches do
          create(:completed_application_form, application_choices: [application_choice], candidate:, recruitment_cycle_year: previous_year)
        end

        expect { candidate.update(email_address: 'new.email@example.com') }
          .not_to(change { application_form.application_choices.first.updated_at })
      end
    end

    context 'with application forms' do
      it 'touches the application form when a field affecting the application form is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(email_address: 'new.email@example.com') }
          .to(change { application_form.reload.updated_at })
      end

      it 'does not touch the application form when a field not affecting the application form is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(last_signed_in_at: Time.zone.now) }
          .not_to(change { application_form.reload.updated_at })
      end

      it 'does not touch the application form when its in a previous recruitment cycle' do
        candidate = create(:candidate)
        application_form = ApplicationForm.with_unsafe_application_choice_touches do
          create(:completed_application_form, application_choices_count: 1, candidate:, recruitment_cycle_year: previous_year)
        end

        expect { candidate.update(email_address: 'new.email@example.com') }
          .not_to(change { application_form.reload.updated_at })
      end
    end
  end

  describe '#delete' do
    it 'deletes all dependent records through cascading deletes in the database' do
      candidate = create(:candidate)
      application_form = create(:application_form, candidate:)
      application_choice = create(:application_choice, application_form:)
      application_work_experience = create(:application_work_experience, experienceable: application_form)
      application_volunteering_experience = create(:application_volunteering_experience, experienceable: application_form)
      application_work_history_break = create(:application_work_history_break, breakable: application_form)
      application_qualification = create(:application_qualification, application_form:)
      application_reference = create(:reference, application_form:)
      preference = create(:candidate_preference, candidate:)
      location_preference = create(:candidate_location_preference, candidate_preference: preference)

      candidate.delete

      expect { candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_form.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_choice.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_work_experience.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_volunteering_experience.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_work_history_break.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_qualification.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_reference.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { preference.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { location_preference.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.for_email' do
    it 'returns a candidate with the given email address' do
      candidate = create(:candidate, email_address: 'candidate@email.address')

      expect(described_class.for_email('candidate@email.address')).to eq(candidate)
    end

    context 'when the email address is not an email address' do
      it 'returns a new candidate with the email address' do
        candidate = described_class.for_email('not_an_email')
        expect(candidate).to be_new_record
        expect(candidate.email_address).to eq('not_an_email')
      end
    end

    context 'when the email address matches a OneLoginAuth' do
      it 'returns the candidate' do
        candidate = create(:candidate, email_address: 'candidate@email.address')
        _one_login_auth = create(:one_login_auth, email_address: 'one_login@email.address', candidate:)

        expect(described_class.for_email('one_login@email.address')).to eq(candidate)
      end
    end

    context 'when the email address matches a Candidate which has a different OneLoginAuth email address' do
      it 'returns the candidate' do
        candidate = create(:candidate, email_address: 'candidate@email.address')
        _one_login_auth = create(:one_login_auth, email_address: 'one_login@email.address', candidate: candidate)

        expect(described_class.for_email('candidate@email.address')).to eq(candidate)
      end
    end
  end

  describe 'Candidates::Safeguarding' do
    describe '.with_safeguarding_concerns' do
      it 'includes candidates with safeguarding concerns declared on their Application Form' do
        candidate_with_safeguarding_concerns = create(:candidate)
        _application_form_with_safeguarding_concerns = create(:application_form,
                                                              candidate: candidate_with_safeguarding_concerns,
                                                              safeguarding_issues_status: :has_safeguarding_issues_to_declare)
        candidate_without_safeguarding_concerns = create(:candidate)
        _application_form_without_safeguarding_concerns = create(:application_form,
                                                                 candidate: candidate_without_safeguarding_concerns,
                                                                 safeguarding_issues_status: :no_safeguarding_issues_to_declare)

        expect(described_class.with_safeguarding_concerns).to contain_exactly(candidate_with_safeguarding_concerns)
      end

      it 'includes candidates with safeguarding concerns declared on their References' do
        candidate_with_safeguarding_concerns = create(:candidate)
        application_form = create(:application_form,
                                  candidate: candidate_with_safeguarding_concerns,
                                  safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _reference_with_safeguarding_concerns = create(:reference,
                                                       application_form: application_form,
                                                       safeguarding_concerns_status: :has_safeguarding_concerns_to_declare)

        candidate_without_safeguarding_concerns = create(:candidate)
        application_form_without_safeguarding_concerns = create(:application_form,
                                                                candidate: candidate_without_safeguarding_concerns,
                                                                safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _reference_without_safeguarding_concerns = create(:reference,
                                                          application_form: application_form_without_safeguarding_concerns,
                                                          safeguarding_concerns_status: :no_safeguarding_concerns_to_declare)

        expect(described_class.with_safeguarding_concerns).to contain_exactly(candidate_with_safeguarding_concerns)
      end

      it 'includes candidates with safeguarding rejection reasons' do
        structured_rejection_reasons_with_safeguarding = { selected_reasons: [{ id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'some detail' } }] }
        candidate_with_safeguarding_rejection = create(:candidate)
        application_form_with_safeguarding_rejection = create(:application_form, candidate: candidate_with_safeguarding_rejection, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _application_choice_with_safeguarding_rejection = create(:application_choice, application_form: application_form_with_safeguarding_rejection, status: :rejected, structured_rejection_reasons: structured_rejection_reasons_with_safeguarding)

        structured_rejection_reasons_without_safeguarding = { selected_reasons: [{ id: 'personal_statement', label: 'Personal statement', selected_reasons: [{ id: 'quality_of_writing', label: 'Quality of writing', details: { id: 'quality_of_writing_details', text: 'Spelling errors' } }] }] }
        candidate_without_safeguarding_rejection = create(:candidate)
        application_form_without_safeguarding_rejection = create(:application_form, candidate: candidate_without_safeguarding_rejection, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _application_choice_without_safeguarding_rejection = create(:application_choice, application_form: application_form_without_safeguarding_rejection, status: :rejected, structured_rejection_reasons: structured_rejection_reasons_without_safeguarding)

        expect(described_class.with_safeguarding_concerns).to contain_exactly(candidate_with_safeguarding_rejection)
      end
    end

    describe '.without_safeguarding_concerns' do
      it 'includes candidates without safeguarding concerns declared on their Application Form or References or Rejection Reasons' do
        candidate_with_safeguarding_concerns_on_application = create(:candidate)
        _application_form_with_safeguarding_concerns = create(:application_form,
                                                              candidate: candidate_with_safeguarding_concerns_on_application,
                                                              safeguarding_issues_status: :has_safeguarding_issues_to_declare)

        candidate_with_safeguarding_concerns_on_reference = create(:candidate)
        application_form_with_reference = create(:application_form,
                                                 candidate: candidate_with_safeguarding_concerns_on_reference,
                                                 safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _reference_with_safeguarding_concerns = create(:reference,
                                                       application_form: application_form_with_reference,
                                                       safeguarding_concerns_status: :has_safeguarding_concerns_to_declare)

        structured_rejection_reasons_with_safeguarding = { selected_reasons: [{ id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'some detail' } }] }
        candidate_with_safeguarding_rejection = create(:candidate)
        application_form_with_safeguarding_rejection = create(:application_form, candidate: candidate_with_safeguarding_rejection, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _application_choice_with_safeguarding_rejection = create(:application_choice, application_form: application_form_with_safeguarding_rejection, status: :rejected, structured_rejection_reasons: structured_rejection_reasons_with_safeguarding)

        candidate_without_safeguarding_concerns = create(:candidate)
        _application_form_without_safeguarding_concerns = create(:application_form,
                                                                 candidate: candidate_without_safeguarding_concerns,
                                                                 safeguarding_issues_status: :no_safeguarding_issues_to_declare)

        expect(described_class.without_safeguarding_concerns).to contain_exactly(candidate_without_safeguarding_concerns)
      end
    end

    describe '#safeguarding_concerns?' do
      it 'returns true if the candidate has safeguarding concerns declared on their Application Form' do
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:, safeguarding_issues_status: :has_safeguarding_issues_to_declare)
        _reference = create(:reference, application_form:, safeguarding_concerns_status: :no_safeguarding_concerns_to_declare)

        expect(candidate.safeguarding_concerns?).to be true
      end

      it 'returns true if the candidate has safeguarding concerns declared on their References' do
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _reference = create(:reference, application_form:, safeguarding_concerns_status: :has_safeguarding_concerns_to_declare)

        expect(candidate.safeguarding_concerns?).to be true
      end

      it 'returns true if the candidate has been rejected due to safeguarding concerns' do
        structured_rejection_reasons = { selected_reasons: [{ id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'some detail' } }] }
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _rejected_application_choice = create(:application_choice, application_form:, status: :rejected, structured_rejection_reasons: structured_rejection_reasons)

        expect(candidate.safeguarding_concerns?).to be true
      end

      it 'returns false if the candidate has no safeguarding concerns declared on their Application Form or References' do
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _reference = create(:reference, application_form:, safeguarding_concerns_status: :no_safeguarding_concerns_to_declare)

        expect(candidate.safeguarding_concerns?).to be false
      end

      it 'returns false if the candidate has no Application Forms or References' do
        candidate = create(:candidate)

        expect(candidate.safeguarding_concerns?).to be false
      end
    end

    describe '#application_forms_with_safeguarding_concerns?' do
      it 'returns false' do
        candidate = create(:candidate)

        expect(candidate.application_forms_with_safeguarding_concerns?).to be false
      end

      it 'returns true if the candidate has safeguarding concerns declared on their Application Form' do
        candidate = create(:candidate)
        _application_form = create(:application_form, candidate:, safeguarding_issues_status: :has_safeguarding_issues_to_declare)

        expect(candidate.application_forms_with_safeguarding_concerns?).to be true
      end
    end

    describe '#application_references_with_safeguarding_concerns?' do
      it 'returns false' do
        candidate = create(:candidate)

        expect(candidate.application_references_with_safeguarding_concerns?).to be false
      end

      it 'returns true if the candidate has safeguarding concerns declared on their References' do
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _reference = create(:reference, application_form:, safeguarding_concerns_status: :has_safeguarding_concerns_to_declare)

        expect(candidate.application_references_with_safeguarding_concerns?).to be true
      end
    end

    describe '#application_choices_rejected_with_safeguarding_concerns?' do
      it 'returns false' do
        candidate = create(:candidate)

        expect(candidate.application_choices_rejected_with_safeguarding_concerns?).to be false
      end

      it 'returns true if the candidate has been rejected due to safeguarding concerns' do
        structured_rejection_reasons = { selected_reasons: [{ id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'some detail' } }] }
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
        _rejected_application_choice = create(:application_choice, application_form:, status: :rejected, structured_rejection_reasons: structured_rejection_reasons)

        expect(candidate.application_choices_rejected_with_safeguarding_concerns?).to be true
      end
    end
  end

  describe '#application_choices_rejected_with_already_qualified?' do
    it 'returns false' do
      candidate = create(:candidate)

      expect(candidate.application_choices_rejected_with_already_qualified?).to be false
    end

    it 'returns true if the candidate has been rejected due to already qualified' do
      structured_rejection_reasons_with_already_qualified = { selected_reasons: [{ id: 'qualifications', label: 'Qualifications', selected_reasons: [{ id: 'already_qualified', label: 'Already has a teaching qualification', details: { id: 'already_qualified_details', text: 'Was previously a teacher' } }] }] }
      candidate = create(:candidate)
      application_form_with_already_qualified_rejection = create(:application_form, candidate: candidate, right_to_work_or_study: 'yes', personal_details_completed: true)
      _application_choice_with_already_qualified_rejection = create(:application_choice, application_form: application_form_with_already_qualified_rejection, status: :rejected, structured_rejection_reasons: structured_rejection_reasons_with_already_qualified)

      expect(candidate.application_choices_rejected_with_already_qualified?).to be true
    end
  end

  describe '#current_application' do
    let(:candidate) { create(:candidate) }

    context 'mid cycle', time: mid_cycle do
      it 'returns an existing application_form' do
        application_form = create(:application_form, candidate:)

        expect(candidate.current_application).to eq(application_form)
      end

      it 'creates an application_form with the current cycle if there are none' do
        expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
        expect(candidate.current_application.recruitment_cycle_year).to eq current_year
      end

      it 'returns the most recent application' do
        first_application = create(:application_form, candidate:, created_at: 3.days.ago)
        create(:application_form, candidate:, created_at: 10.days.ago)

        expect(candidate.current_application.created_at).to eq(first_application.created_at)
      end
    end

    context 'after the apply deadline', time: after_apply_deadline do
      it 'returns an existing application_form' do
        application_form = create(:application_form, candidate:)

        expect(candidate.current_application).to eq(application_form)
      end

      it 'creates an application_form in the next cycle if there are none' do
        expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
        expect(candidate.current_application.recruitment_cycle_year).to eq next_year
      end
    end
  end

  describe '#current_application_choices' do
    let(:candidate) { create(:candidate) }

    context 'with a single application choice' do
      let!(:application_choice) { create(:application_choice, candidate:) }

      it 'returns the application choice' do
        expect(candidate.current_application_choices).to contain_exactly(application_choice)
      end
    end

    context 'with multiple application choices' do
      let(:application_choice_2) { create(:application_choice, candidate:, created_at: 1.day.ago) }
      let(:application_choice_1) { create(:application_choice, candidate:, created_at: 1.week.ago) }
      let(:application_choice_3) { create(:application_choice, candidate:) }
      let!(:application_form) { create(:application_form, candidate:, application_choices: [application_choice_2, application_choice_1, application_choice_3]) }

      it 'returns all the application choices' do
        expect(candidate.current_application_choices).to contain_exactly(application_choice_1, application_choice_2, application_choice_3)
      end
    end

    context 'with applications in different phases' do
      let(:application_choice_1) { create(:application_choice, candidate:) }
      let(:application_choice_2) { create(:application_choice, candidate:) }
      let(:application_choice_3) { create(:application_choice, candidate:) }
      let!(:application_form_apply_1) { create(:application_form, candidate:, application_choices: [application_choice_1], created_at: 1.week.ago) }
      let!(:application_form_apply_2) { create(:application_form, phase: 'apply_2', candidate:, application_choices: [application_choice_2, application_choice_3]) }

      it 'returns the most recent application choices' do
        expect(candidate.current_application_choices).to contain_exactly(application_choice_2, application_choice_3)
      end
    end
  end

  describe 'find_from_course' do
    it 'returns the correct course' do
      course = create(:course)
      candidate = create(:candidate, course_from_find_id: course.id)

      expect(candidate.course_from_find).to eq(course)
    end

    it 'returns nil if there is no course_from_find_id' do
      candidate = create(:candidate)

      expect(candidate.course_from_find).to be_nil
    end
  end

  describe '#in_apply_2?' do
    subject(:candidate) { build(:candidate) }

    let!(:application_form) { create(:application_form, candidate:) }

    context 'when the candidate has no applications in apply again' do
      it 'returns false' do
        expect(candidate.in_apply_2?).to be false
      end
    end

    context 'when the candidate has applications in apply again' do
      let!(:application_form) { create(:application_form, candidate:, phase: 'apply_2') }

      it 'returns true' do
        expect(candidate.in_apply_2?).to be true
      end
    end

    context 'when the candidate has applications in apply again in previous cycle' do
      let!(:application_form_previous_year) { create(:application_form, candidate:, phase: 'apply_2', recruitment_cycle_year: previous_year) }
      let!(:application_form) { create(:application_form, candidate:) }

      it 'returns true' do
        expect(candidate.in_apply_2?).to be false
      end
    end
  end

  describe '#load_tester?' do
    context 'environment is production' do
      before { allow(HostingEnvironment).to receive(:production?).and_return true }

      it 'returns false regardless of the email address pattern' do
        candidate = build(:candidate, email_address: 'someone@loadtest.example.com')
        expect(candidate).not_to be_load_tester
        candidate.email_address = 'someone@example.com'
        expect(candidate).not_to be_load_tester
      end
    end

    context 'environment is not production' do
      before { allow(HostingEnvironment).to receive(:production?).and_return false }

      it 'returns true if email address is for load testing' do
        candidate = build(:candidate, email_address: 'someone@loadtest.example.com')
        expect(candidate).to be_load_tester
      end

      it 'returns false if email is not for load testing' do
        candidate = build(:candidate, email_address: 'someone@example.com')
        expect(candidate).not_to be_load_tester
      end
    end
  end

  describe '#pseudonymised_id' do
    it 'returns the pseudonymised id based on the candidate id' do
      candidate = build_stubbed(:candidate, id: 0)
      expect(candidate.pseudonymised_id).to eq '5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9'
    end
  end

  context 'scopes' do
    describe '#for_transaction_emails' do
      let!(:unsubscribed_from_emails) { create(:candidate, unsubscribed_from_emails: true) }
      let!(:submission_blocked) { create(:candidate, submission_blocked: true) }
      let!(:account_locked) { create(:candidate, account_locked: true) }
      let!(:free_to_email) { create(:candidate, account_locked: false, unsubscribed_from_emails: false, submission_blocked: false) }

      it 'excludes candidates whose accounts are blocked or locked' do
        expect(described_class.for_transaction_emails).to contain_exactly(unsubscribed_from_emails, free_to_email)
      end
    end

    describe '#for_marketing_or_nudge_emails' do
      let!(:unsubscribed_from_emails) { create(:candidate, unsubscribed_from_emails: true) }
      let!(:submission_blocked) { create(:candidate, submission_blocked: true) }
      let!(:account_locked) { create(:candidate, account_locked: true) }
      let!(:free_to_email) { create(:candidate, account_locked: false, unsubscribed_from_emails: false, submission_blocked: false) }

      it 'excludes blocked, locked and unsubscribed emails' do
        expect(described_class.for_marketing_or_nudge_emails).to contain_exactly(free_to_email)
      end
    end
  end

  describe '#recoverable?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, candidate:) }

    it 'returns false if one login bypass' do
      expect(candidate.recoverable?).to be_falsey
    end

    it 'returns false if one login feature flag is not enabled' do
      FeatureFlag.deactivate(:one_login_candidate_sign_in)

      expect(candidate.recoverable?).to be_falsey
    end

    it 'returns false if candidate has not got a one login auth' do
      FeatureFlag.activate(:one_login_candidate_sign_in)
      allow(OneLogin).to receive(:bypass?).and_return(false)

      expect(candidate.recoverable?).to be_falsey
    end

    context 'when candidate dismissed the banner' do
      let(:candidate) { create(:candidate, account_recovery_status: :dismissed) }

      it 'returns false' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(false)

        expect(candidate.recoverable?).to be_falsey
      end
    end

    context 'when candidate recovered their account' do
      let(:candidate) { create(:candidate, account_recovery_status: :recovered) }

      it 'returns false' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(false)

        expect(candidate.recoverable?).to be_falsey
      end
    end

    context 'when candidate has submitted applications choices' do
      let(:candidate) { create(:candidate, account_recovery_status: :not_started) }

      it 'returns false' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(false)
        create(:application_form, :with_accepted_offer, candidate:)

        expect(candidate.recoverable?).to be_falsey
      end
    end

    context 'when candidate does not have submitted application choices' do
      let(:candidate) do
        create(
          :candidate,
          :with_live_session,
          account_recovery_status: :not_started,
        )
      end

      it 'returns true' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(false)

        expect(candidate.recoverable?).to be_truthy
      end
    end
  end

  describe '#one_login_connected?' do
    let(:candidate) { create(:candidate) }

    context 'when the candidate has a OneLoginAuth record' do
      before { create(:one_login_auth, candidate:) }

      it 'returns true' do
        expect(candidate.one_login_connected?).to be true
      end
    end

    context 'when the candidate does not have a OneLoginAuth record' do
      it 'returns false' do
        expect(candidate.one_login_connected?).to be false
      end
    end
  end

  describe '#redacted_full_name_current_cycle' do
    it 'returns the redacted full_name from the application form in current cycle' do
      candidate = create(:candidate)
      _current_cycle_form = create(
        :application_form,
        :completed,
        candidate:,
        first_name: 'test',
        last_name: 'test',
      )

      _last_cycle_form = create(
        :application_form,
        :completed,
        recruitment_cycle_year: previous_year,
        candidate:,
        first_name: 'last',
        last_name: 'cycle',
      )

      expect(candidate.redacted_full_name_current_cycle).to eq('t***** t*****')
    end
  end

  describe '#applied_only_to_salaried_courses?' do
    it 'returns true if applied only to salary or apprenticeship course' do
      application_form = create(
        :application_form,
        :completed,
      )
      salary_course = create(:course, funding_type: 'salary')
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option: create(:course_option, course: salary_course),
      )
      apprenticeship_course = create(:course, funding_type: 'apprenticeship')
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option: create(:course_option, course: apprenticeship_course),
      )

      candidate = application_form.candidate

      expect(candidate.applied_only_to_salaried_courses?).to be(true)
    end

    it 'returns false if appliedto salary, apprenticeship and fee course' do
      application_form = create(
        :application_form,
        :completed,
      )
      salary_course = create(:course, funding_type: 'salary')
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option: create(:course_option, course: salary_course),
      )
      apprenticeship_course = create(:course, funding_type: 'apprenticeship')
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option: create(:course_option, course: apprenticeship_course),
      )
      fee_course = create(:course, funding_type: 'fee')
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option: create(:course_option, course: fee_course),
      )

      candidate = application_form.candidate

      expect(candidate.applied_only_to_salaried_courses?).to be(false)
    end
  end
end
