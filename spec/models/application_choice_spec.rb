require 'rails_helper'

RSpec.describe ApplicationChoice do
  it { is_expected.to have_many(:work_experiences).class_name('ApplicationWorkExperience') }
  it { is_expected.to have_many(:volunteering_experiences).class_name('ApplicationVolunteeringExperience') }
  it { is_expected.to have_many(:work_history_breaks).class_name('ApplicationWorkHistoryBreak') }

  describe 'delegations' do
    it { is_expected.to delegate_method(:pending_conditions).to(:offer).allow_nil.with_prefix }
    it { is_expected.to delegate_method(:unmet_conditions).to(:offer).allow_nil.with_prefix }
    it { is_expected.to delegate_method(:met_conditions).to(:offer).allow_nil.with_prefix }
  end

  describe 'auditing', :with_audited do
    it 'creates audit entries' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      expect(application_choice.audits.count).to eq 1
      application_choice.update!(status: 'awaiting_provider_decision')
      expect(application_choice.audits.count).to eq 2
    end

    it 'creates an associated object in each audit record' do
      application_choice = create(:application_choice)
      expect(application_choice.audits.last.associated).to eq application_choice.application_form
    end

    it 'audit record can be attributed to a candidate' do
      candidate = create(:candidate)
      application_choice = Audited.audit_class.as_user(candidate) do
        create(:application_choice)
      end
      expect(application_choice.audits.last.user).to eq candidate
    end
  end

  describe '.visible_to_provider' do
    it 'returns nothing when there are no records with status in visible_to_provider' do
      (ApplicationStateChange.valid_states - ApplicationStateChange.states_visible_to_provider).each do |status|
        create(:application_choice, status:)
      end

      expect(described_class.visible_to_provider).to be_empty
    end

    it 'scopes to visible_to_provider choices' do
      (ApplicationStateChange.valid_states - ApplicationStateChange.states_visible_to_provider).each do |state|
        create(:application_choice, status: state)
      end
      visible_to_provider = ApplicationStateChange.states_visible_to_provider.map do |state|
        create(:application_choice, status: state)
      end

      expect(described_class.visible_to_provider.pluck(:status)).to match_array(visible_to_provider.map(&:status))
    end
  end

  describe '.not_reappliable' do
    it 'returns nothing when there are no records with status in non_reapply_states' do
      (ApplicationStateChange.valid_states - ApplicationStateChange.non_reapply_states).each do |status|
        create(:application_choice, status:)
      end

      expect(described_class.not_reappliable).to be_empty
    end

    it 'scopes to non_reapply_states choices' do
      (ApplicationStateChange.valid_states - ApplicationStateChange.non_reapply_states).each do |state|
        create(:application_choice, status: state)
      end
      not_reappliable = ApplicationStateChange.non_reapply_states.map do |state|
        create(:application_choice, status: state)
      end

      expect(described_class.not_reappliable.pluck(:status)).to match_array(not_reappliable.map(&:status))
    end
  end

  describe '.reappliable' do
    it 'returns nothing when there are no records with status in non_reapply_states' do
      ApplicationStateChange.non_reapply_states.each do |status|
        create(:application_choice, status:)
      end

      expect(described_class.reappliable).to be_empty
    end

    it 'scopes to REAPPLY_STATUSES choices' do
      (ApplicationStateChange.valid_states - ApplicationStateChange::REAPPLY_STATUSES).each do |state|
        create(:application_choice, status: state)
      end
      reappliable = ApplicationStateChange::REAPPLY_STATUSES.map do |state|
        create(:application_choice, status: state)
      end

      expect(described_class.reappliable.pluck(:status)).to match_array(reappliable.map(&:status))
    end
  end

  describe '.decision_pending' do
    it 'returns nothing when there are no awaiting_provider_decision or interviewing application choices' do
      create(:application_choice, :offered)

      expect(described_class.decision_pending).to be_empty
    end

    it 'scopes to awaiting_provider_decision and interviewing application choices' do
      (ApplicationStateChange.valid_states - ApplicationStateChange::DECISION_PENDING_STATUSES).each do |state|
        create(:application_choice, status: state)
      end
      choice_awaiting_decision = create(:application_choice, :awaiting_provider_decision)
      interviewing_choice = create(:application_choice, status: :interviewing)

      expect(described_class.decision_pending).to contain_exactly(choice_awaiting_decision, interviewing_choice)
    end
  end

  describe '.accepted' do
    it 'returns nothing when there are no pending_conditions, conditions_not_met, recruited or offer_deferred choices' do
      create(:application_choice, :offered)

      expect(described_class.accepted).to be_empty
    end

    it 'returns all pending_conditions, conditions_not_met, recruited or offer_deferred statuses' do
      ApplicationStateChange.valid_states.each { |state| create(:application_choice, status: state) }

      expect(described_class.accepted.map(&:status)).to match_array(ApplicationStateChange::ACCEPTED_STATES.map(&:to_s))
    end
  end

  describe '#decision_pending?' do
    it 'returns false for choices in states not requiring provider action' do
      (ApplicationStateChange.valid_states - ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES).each do |state|
        application_choice = build_stubbed(:application_choice, status: state)
        expect(application_choice.decision_pending?).to be(false)
      end
    end

    it 'returns true for awaiting_provider_decision and interviewing application choices' do
      choice_awaiting_decision = build_stubbed(:application_choice, :awaiting_provider_decision)
      interviewing_choice = build_stubbed(:application_choice, :interviewing)

      expect(choice_awaiting_decision.decision_pending?).to be(true)
      expect(interviewing_choice.decision_pending?).to be(true)
    end
  end

  describe '#course_full?' do
    context 'with 3 options all full' do
      it 'returns true' do
        course = create(:course)
        create_list(:course_option, 3, vacancy_status: :no_vacancies, course:)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.course_full?).to be true
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns false' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course:)
        create(:course_option, vacancy_status: :vacancies, course:)
        application_choice = create(:application_choice, course_option: course_option_without_vacancies)
        expect(application_choice.course_full?).to be false
      end
    end
  end

  describe '#site_full?' do
    context 'with 3 options all full' do
      it 'returns true' do
        course = create(:course)
        create_list(:course_option, 3, vacancy_status: :no_vacancies, course:)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.site_full?).to be true
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns true' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course:)
        create(:course_option, vacancy_status: :vacancies, course:)
        application_choice = create(:application_choice, course_option: course_option_without_vacancies)
        expect(application_choice.site_full?).to be true
      end
    end

    context 'with 2 options for same site only 1 full' do
      it 'returns true' do
        course = create(:course)
        site = create(:site, provider: course.provider)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course:, site:, study_mode: 'full_time')
        create(:course_option, vacancy_status: :vacancies, course:, site:, study_mode: 'part_time')
        application_choice = create(:application_choice, course_option: course_option_without_vacancies)
        expect(application_choice.site_full?).to be false
      end
    end
  end

  describe '#site_invalid?' do
    context 'a course option has been removed by the provider' do
      it 'returns true' do
        course_option = build(:course_option, site_still_valid: false)
        application_choice = create(:application_choice, course_option:)
        expect(application_choice.site_invalid?).to be true
      end
    end

    context 'a course option is still valid' do
      it 'returns false' do
        course_option = build(:course_option, site_still_valid: true)
        application_choice = create(:application_choice, course_option:)
        expect(application_choice.site_invalid?).to be false
      end
    end
  end

  describe '#course_study_mode_full?' do
    context 'with option that has vacancies' do
      it 'returns false' do
        course = create(:course)
        create(:course_option, vacancy_status: :vacancies, course:)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.study_mode_full?).to be false
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns true' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course:)
        create(:course_option, vacancy_status: :vacancies, course:)
        application_choice = create(:application_choice, course_option: course_option_without_vacancies)
        expect(application_choice.study_mode_full?).to be true
      end
    end

    context 'with 2 options for same site only 1 full' do
      it 'returns true' do
        course = create(:course)
        site = create(:site, provider: course.provider)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course:, site:, study_mode: 'full_time')
        create(:course_option, vacancy_status: :vacancies, course:, site:, study_mode: 'part_time')
        application_choice = create(:application_choice, course_option: course_option_without_vacancies)
        expect(application_choice.study_mode_full?).to be true
      end
    end
  end

  describe '#no_feedback?' do
    it 'returns false if simple rejection reason is provided' do
      application_choice = build(:application_choice, :rejected)

      expect(application_choice.no_feedback?).to be false
    end

    it 'returns false if structured rejection reasons are provided' do
      application_choice = build(:application_choice, :with_old_structured_rejection_reasons)

      expect(application_choice.no_feedback?).to be false
    end

    it 'returns true if no feedback for the candidate is provided' do
      application_choice = build(:application_choice)

      expect(application_choice.no_feedback?).to be true
    end
  end

  describe 'validations' do
    let(:application_form) { create(:application_form) }
    let(:course_option) { create(:course_option) }

    context 'when the application is not in a reappliable state' do
      ApplicationStateChange.non_reapply_states.each do |status|
        it "validates uniqueness of course option to form when status is '#{status}'" do
          create(:application_choice, application_form:, course_option:, status: status)

          application_choice = build(:application_choice, application_form:, course_option:, status: status)
          expect(application_choice).not_to be_valid
          expect(application_choice.errors[:base]).to include('cannot apply to the same course when an open application exists')
        end
      end
    end

    context 'when the application is in a reappliable state' do
      ApplicationStateChange::REAPPLY_STATUSES.each do |status|
        it "does not enforce unique application form and course option when status is '#{status}'" do
          create(:application_choice, application_form:, course_option:, status: status)

          application_choice = build(:application_choice, application_form:, course_option:, status: status)
          expect(application_choice).to be_valid
        end
      end
    end

    context 'when updating the status of an reappliable application to open and an open one already exists for the same course' do
      let(:course) { create(:course) }
      let(:first_course_option) { create(:course_option, course:) }
      let(:second_course_option) { create(:course_option, course:) }
      let(:rejected) { build(:application_choice, :rejected, course_option: first_course_option) }
      let(:unsubmitted) { build(:application_choice, :unsubmitted, course_option: second_course_option) }

      before do
        create(:application_form, application_choices: [rejected, unsubmitted])
      end

      it 'fails validation' do
        result = rejected.update(status: :unsubmitted)
        expect(result).to be false
        expect(rejected.errors.full_messages).to include('cannot apply to the same course when an open application exists')
      end
    end
  end

  describe '#structured_rejection_reasons' do
    it 'are serialized and rehydrateable' do
      reasons = ReasonsForRejection.new(
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Used the wrong spoon for soup',
      )

      application_choice = create(:application_choice)
      application_choice.update!(structured_rejection_reasons: reasons)

      rehydrated_reasons = ReasonsForRejection.new(application_choice.reload.structured_rejection_reasons)
      expect(rehydrated_reasons.candidate_behaviour_y_n).to eq('Yes')
      expect(rehydrated_reasons.candidate_behaviour_what_did_the_candidate_do).to eq(%w[other])
      expect(rehydrated_reasons.candidate_behaviour_other).to eq('Used the wrong spoon for soup')
    end
  end

  describe '#associated_providers' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:) }
    let(:course_option) { create(:course_option, course:) }
    let(:provider) { create(:provider) }
    let(:provider_user) { create(:provider_user, :with_make_decisions, providers: [provider]) }
    let(:accredited_provider) { create(:provider) }

    context 'when the application course has both a provider and an accredited provider' do
      let(:course) { create(:course, provider:) }

      it 'retrieves both providers' do
        expect(application_choice.associated_providers).to contain_exactly(provider)
      end
    end

    context 'when the application course only has a provider set' do
      let(:course) { create(:course, provider:, accredited_provider:) }

      it 'retrieves the ratifying provider' do
        expect(application_choice.associated_providers).to contain_exactly(provider, accredited_provider)
      end
    end

    context 'when the application course provider and accredited provider are the same' do
      let(:course) { create(:course, provider:, accredited_provider: provider) }

      it 'retrieves the training provider' do
        expect(application_choice.associated_providers).to contain_exactly(provider)
      end
    end
  end

  describe '#unconditional_offer_pending_recruitment?' do
    context 'recruited with conditions' do
      it 'returns false' do
        application_choice = build_stubbed(:application_choice, :recruited)
        expect(application_choice.unconditional_offer_pending_recruitment?).to be false
      end
    end

    context 'recruited unconditionally' do
      it 'returns true' do
        application_choice = build_stubbed(:application_choice, :recruited, offer: create(:unconditional_offer))

        expect(application_choice.unconditional_offer_pending_recruitment?).to be true
      end
    end

    context 'all other statuses' do
      it 'returns false' do
        statuses = described_class.statuses.values.reject { |value| value == 'recruited' }

        statuses.each do |status|
          application_choice = build_stubbed(:application_choice, status:)
          expect(application_choice.unconditional_offer_pending_recruitment?).to be false
        end
      end
    end
  end

  describe '#unconditional_offer' do
    context 'when the offer has no conditions' do
      it 'returns true' do
        application_choice = build_stubbed(:application_choice, :recruited, offer: create(:unconditional_offer))

        expect(application_choice.unconditional_offer?).to be true
      end
    end

    context 'when the offer has conditions' do
      it 'returns false' do
        application_choice = build_stubbed(:application_choice, :offered, offer: create(:offer))

        expect(application_choice.unconditional_offer?).to be false
      end
    end
  end

  describe '#withdrawn_at_candidates_request?' do
    it 'is false when the application has been withdrawn by the candidate' do
      application_choice = build_stubbed(:application_choice, :withdrawn)

      expect(application_choice.withdrawn_at_candidates_request?).to be false
    end

    it 'is true when the application has been withdrawn at the candidate\'s request' do
      application_choice = build_stubbed(:application_choice, :withdrawn)
      create(:withdrawn_at_candidates_request_audit, application_choice:)

      expect(application_choice.withdrawn_at_candidates_request?).to be true
    end
  end

  describe '#configure_initial_course_choice!' do
    let(:application_choice) { create(:application_choice) }
    let(:course_option) { create(:course_option) }

    it 'sets original_course_option and course_option' do
      expect { application_choice.configure_initial_course_choice! course_option }
        .to change(application_choice, :original_course_option).to(course_option)
        .and change(application_choice, :course_option).to(course_option)
        .and change(application_choice, :current_course_option).to(course_option)
    end
  end

  describe '#update_course_option_and_associated_fields!' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
    let(:course) { create(:course, :with_accredited_provider, :previous_year) }
    let(:course_option) { create(:course_option, course:) }

    it 'sets current_course_option_id' do
      expect { application_choice.update_course_option_and_associated_fields! course_option }
        .to change(application_choice, :current_course_option_id).to(course_option.id)
    end

    it 'sets personal_statement attribute eql to application form.becoming_a_teacher' do
      application_choice.application_form = create(:application_form, becoming_a_teacher: 'I want to be a teacher')
      expect { application_choice.update_course_option_and_associated_fields! course_option }
        .to change(application_choice, :personal_statement).to('I want to be a teacher')
    end

    it 'sets current_recruitment_cycle_year' do
      expected_year = course.recruitment_cycle_year

      expect { application_choice.update_course_option_and_associated_fields! course_option }
        .to change(application_choice, :current_recruitment_cycle_year).to(expected_year)
    end

    it 'can set additional fields in same operation' do
      expect {
        application_choice.update_course_option_and_associated_fields!(course_option, other_fields: {
          recruited_at: 1.hour.from_now,
        })
      }.to change(application_choice, :recruited_at)
    end

    it 'supports setting audit_comment', :with_audited do
      application_choice.update_course_option_and_associated_fields!(course_option, audit_comment: 'zendesk')
      expect(application_choice.audits.last.comment).to eq('zendesk')
    end

    context 'provider ids' do
      it 'updates provider_ids from the current course' do
        expected_ids = [
          application_choice.provider.id,
          course.provider.id,
          course.accredited_provider.id,
        ]

        expect { application_choice.update_course_option_and_associated_fields! course_option }
          .to change(application_choice, :provider_ids).to(expected_ids)
      end

      it 'updates course_option and current_course_option provider_ids if new courses are provided' do
        new_course = create(:course, :with_accredited_provider)
        new_course_option = create(:course_option, course: new_course)
        changed_course = create(:course, :with_accredited_provider)
        changed_course_option = create(:course_option, course: changed_course)

        expected_ids = [
          changed_course_option.provider.id,
          changed_course_option.accredited_provider.id,
          new_course.provider.id,
          new_course.accredited_provider.id,
        ]

        expect { application_choice.update_course_option_and_associated_fields!(new_course_option, other_fields: { course_option: changed_course_option }) }
          .to change(application_choice, :provider_ids).to(expected_ids)
      end
    end
  end

  describe '#provider_ids_for_access' do
    let(:course) { create(:course) }
    let(:course_option) { create(:course_option, course:) }
    let(:application_choice) { create(:application_choice, course_option:) }

    context 'associated to course with training provider only' do
      it 'returns training provider id' do
        expect(application_choice.provider_ids_for_access).to contain_exactly(course.provider.id)
      end
    end

    context 'associated to course with training and accredited provider' do
      let(:course) { create(:course, :with_accredited_provider) }

      it 'returns training and accredited provider id' do
        expect(application_choice.provider_ids_for_access)
          .to contain_exactly(
            course.provider.id,
            course.accredited_provider.id,
          )
      end
    end

    context 'associated to multiple courses with training and accredited providers' do
      let(:course) { create(:course, :with_accredited_provider) }
      let(:another_course) { create(:course, :with_accredited_provider) }
      let(:another_course_option) { create(:course_option, course: another_course) }
      let(:application_choice) do
        create(:application_choice, course_option:, current_course_option: another_course_option)
      end

      it 'returns training and accredited provider ids for all courses' do
        expect(application_choice.provider_ids_for_access)
          .to contain_exactly(
            course.provider.id,
            course.accredited_provider.id,
            another_course.provider.id,
            another_course.accredited_provider.id,
          )
      end
    end
  end

  describe '#science_gcse_needed?' do
    it 'is true for primary courses' do
      course = create(:course, level: 'primary')
      course_option = create(:course_option, course:)
      application_choice = create(:application_choice, course_option:)
      expect(application_choice.science_gcse_needed?).to be true
    end

    it 'is false for secondary courses' do
      course = create(:course, level: 'secondary')
      course_option = create(:course_option, course:)
      application_choice = create(:application_choice, course_option:)

      expect(application_choice.science_gcse_needed?).to be false
    end
  end

  describe '#days_since_sent_to_provider' do
    let(:application_choice) { create(:application_choice, sent_to_provider_at: sent_to_provider_at) }

    context 'when sent_to_provider_at is nil' do
      let(:sent_to_provider_at) { nil }

      it 'returns nil' do
        expect(application_choice.days_since_sent_to_provider).to be_nil
      end
    end

    context 'when sent_to_provider_at is a valid date' do
      let(:sent_to_provider_at) { 5.days.ago }

      it 'returns the number of days since the submission' do
        expect(application_choice.days_since_sent_to_provider).to eq(5)
      end
    end
  end

  describe '#days_since_offered' do
    let(:application_choice) { create(:application_choice, offered_at: offered_at) }

    context 'when offered_at is nil' do
      let(:offered_at) { nil }

      it 'returns nil' do
        expect(application_choice.days_since_offered).to be_nil
      end
    end

    context 'when offered_at is a valid date' do
      let(:offered_at) { 5.days.ago }

      it 'returns the number of days since the submission' do
        expect(application_choice.days_since_offered).to eq(5)
      end
    end
  end

  describe '#supplementary_statuses' do
    let(:service) { instance_double(RecruitedWithPendingConditions, call: true) }

    before { allow(RecruitedWithPendingConditions).to receive(:new).and_return(service) }

    it 'returns an empty array if the status is not `recruited`' do
      application_choice = build(:application_choice, :offer)
      expect(application_choice.supplementary_statuses).to eq([])
    end

    it 'returns `ske_pending_conditions` if the status is `recruited`' do
      application_choice = build(:application_choice, :recruited)
      expect(application_choice.supplementary_statuses).to eq([:ske_pending_conditions])
    end
  end

  describe '#updated_recently_since_submitted?' do
    before do
      allow(RecentlyUpdatedApplicationChoice).to receive(:new).and_return(
        instance_double(RecentlyUpdatedApplicationChoice, call: service_response),
      )
    end

    let(:choice) { build_stubbed(:application_choice) }

    context 'when the service returns true' do
      let(:service_response) { true }

      it 'is not recently updated' do
        expect(choice).to be_updated_recently_since_submitted
      end
    end

    context 'when the service returns false' do
      let(:service_response) { false }

      it 'is not recently updated' do
        expect(choice).not_to be_updated_recently_since_submitted
      end
    end
  end

  describe '#application_work_experiences' do
    context 'when application_choice has work experiences' do
      it 'returns the application choice work experiences' do
        application_form = create(:application_form)
        create(:application_work_experience, experienceable: application_form)
        choice = create(:application_choice, application_form:)
        create(:application_work_experience, experienceable: choice)

        expect(choice.application_work_experiences).to eq(choice.work_experiences)
        expect(choice.application_work_experiences).not_to eq(
          application_form.application_work_experiences,
        )
      end
    end

    context 'when application_choice has no work experiences' do
      it 'returns the application form work experiences' do
        application_form = create(:application_form)
        create(:application_work_experience, experienceable: application_form)
        choice = create(:application_choice, application_form:)

        expect(choice.application_work_experiences).to eq(
          application_form.application_work_experiences,
        )
        expect(choice.application_work_experiences).not_to eq(
          choice.work_experiences,
        )
      end
    end
  end

  describe '#application_volunteering_experiences' do
    context 'when application_choice has volunteering experiences' do
      it 'returns the application choice volunteering experiences' do
        application_form = create(:application_form)
        create(:application_volunteering_experience, experienceable: application_form)
        choice = create(:application_choice, application_form:)
        create(:application_volunteering_experience, experienceable: choice)

        expect(choice.application_volunteering_experiences).to eq(choice.volunteering_experiences)
        expect(choice.application_volunteering_experiences).not_to eq(
          application_form.application_volunteering_experiences,
        )
      end
    end

    context 'when application_choice has no volunteering experiences' do
      it 'returns the application form volunteering experiences' do
        application_form = create(:application_form)
        create(:application_volunteering_experience, experienceable: application_form)
        choice = create(:application_choice, application_form:)

        expect(choice.application_volunteering_experiences).to eq(
          application_form.application_volunteering_experiences,
        )
        expect(choice.application_volunteering_experiences).not_to eq(
          choice.volunteering_experiences,
        )
      end
    end
  end

  describe '#application_work_history_breaks' do
    context 'when application_choice has volunteering experiences' do
      it 'returns the application choice volunteering experiences' do
        application_form = create(:application_form)
        create(:application_work_history_break, breakable: application_form)
        choice = create(:application_choice, application_form:)
        create(:application_work_history_break, breakable: choice)

        expect(choice.application_work_history_breaks).to eq(choice.work_history_breaks)
        expect(choice.application_work_history_breaks).not_to eq(
          application_form.application_work_history_breaks,
        )
      end
    end

    context 'when application_choice has no volunteering experiences' do
      it 'returns the application form volunteering experiences' do
        application_form = create(:application_form)
        create(:application_work_history_break, breakable: application_form)
        choice = create(:application_choice, application_form:)

        expect(choice.application_work_history_breaks).to eq(
          application_form.application_work_history_breaks,
        )
        expect(choice.application_work_history_breaks).not_to eq(
          choice.work_history_breaks,
        )
      end
    end
  end

  describe '#undergraduate_course_and_application_form_with_degree?' do
    let(:application_choice) { create(:application_choice, current_course_option: current_course_option, application_form:) }
    let(:application_form) { create(:application_form) }
    let(:current_course_option) { create(:course_option, course: current_course) }
    let(:current_course) { create(:course, program_type: 'teacher_degree_apprenticeship') }

    context 'when the course is an undergraduate and the application form has a degree' do
      it 'returns true' do
        create(:application_qualification, level: 'degree', application_form:)

        expect(application_choice.undergraduate_course_and_application_form_with_degree?).to be(true)
      end
    end

    context 'when the course is not undergraduate but the application form has a degree' do
      let(:current_course) { create(:course, program_type: 'pg_teaching_apprenticeship') }

      it 'returns false' do
        create(:application_qualification, level: 'degree', application_form:)

        expect(application_choice.undergraduate_course_and_application_form_with_degree?).to be(false)
      end
    end

    context 'when the course is undergraduate but the application form does not have a degree' do
      it 'returns false' do
        expect(application_choice.undergraduate_course_and_application_form_with_degree?).to be(false)
      end
    end

    context 'when neither the course is undergraduate nor the application form has a degree' do
      let(:current_course) { create(:course, program_type: 'pg_teaching_apprenticeship') }

      it 'returns false' do
        expect(application_choice.undergraduate_course_and_application_form_with_degree?).to be(false)
      end
    end
  end
end
