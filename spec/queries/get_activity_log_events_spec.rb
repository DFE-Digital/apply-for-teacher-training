require 'rails_helper'

RSpec.describe GetActivityLogEvents, :with_audited do
  let(:provider_user) { create(:provider_user, :with_two_providers) }
  let(:application_choices_for_provider_user) { GetApplicationChoicesForProviders.call(providers: provider_user.providers) }
  let(:service_call) { described_class.call(application_choices: application_choices_for_provider_user) }

  let(:course_provider_a) { create(:course, provider: provider_user.providers.first) }
  let(:course_provider_b) { create(:course, provider: provider_user.providers.second) }
  let(:course_unrelated) { create(:course) }
  let(:ratified_course_provider_b) { create(:course, accredited_provider: provider_user.providers.second) }
  let(:ratified_course_unrelated) { create(:course, accredited_provider: create(:provider)) }

  def create_application_choice_for_course(course)
    course_option = course.course_options.first
    course_option ||= create(:course_option, course:)
    create(:application_choice, :awaiting_provider_decision, course_option:)
  end

  def create_audit_for_application_choice(application_choice)
    create(:application_choice_audit, :with_offer, user: provider_user, application_choice:)
  end

  def create_audit_for_application_form(application_choice)
    create(:application_form_audit, user: provider_user, application_choice:, changes: { 'first_name' => %w[A B] })
  end

  describe '#call' do
    it 'returns an empty array if no audits are found' do
      expect(service_call).to eq([])
    end

    it 'returns objects responding to the required attributes' do
      choice = create_application_choice_for_course course_provider_a
      create_audit_for_application_choice choice

      result = service_call

      expect(result.size).to eq(1)

      %i[created_at auditable].each do |attr|
        expect(result.first).to respond_to(attr)
      end
    end

    it 'supports an since: argument for limiting number of events' do
      choice = create_application_choice_for_course course_provider_a
      create_audit_for_application_choice choice

      expected = create(
        :application_choice_audit,
        :with_offer,
        user: provider_user,
        application_choice: choice,
        created_at: 1.day.from_now,
      )

      result = described_class.call(
        application_choices: application_choices_for_provider_user,
        since: 6.hours.from_now,
      )

      expect(result.first).to eq(expected)
    end
  end

  context 'includes all and only relevant audits' do
    it 'filters on action == update' do
      choice = create_application_choice_for_course course_provider_a

      result = service_call

      expect(choice.audits.count).to eq(1)
      expect(choice.audits.first.action).to eq('create')
      expect(result.size).to eq(0)
    end

    it 'excludes events when not all keys are editable' do
      choice = create_application_choice_for_course course_provider_a
      audit = create(
        :application_form_audit,
        application_choice: choice,
        changes: {
          'interview_preferences' => %w[This That],
          'becoming_a_teacher_completed' => %w[true false],
        },
      )

      result = service_call

      expect(result).not_to include(audit)
    end

    it 'excludes events when ApplicationForm untracked attrs are changed' do
      choice = create_application_choice_for_course course_provider_a
      audit = create(
        :application_form_audit,
        application_choice: choice,
        changes: {
          'date_of_birth' => %w[Hello Hi],
          'first_name' => %w[Hello Hi],
          'last_name' => %w[Hello Hi],
          'phone_number' => %w[Hello Hi],
          'address_line1' => %w[Hello Hi],
          'address_line2' => %w[Hello Hi],
          'address_line3' => %w[Hello Hi],
          'address_line4' => %w[Hello Hi],
          'country' => %w[Hello Hi],
          'postcode' => %w[Hello Hi],
          'region_code' => %w[Hello Hi],
          'interview_preferences' => %w[Hello Hi],
          'disability_disclosure' => %w[Hello Hi],

          # Untracked attribute
          'maths_gcse_completed' => %w[Hello Hi],
        },
      )

      result = service_call

      expect(result).not_to include(audit)
    end

    it 'includes events when ApplicationForm attrs are changed' do
      choice = create_application_choice_for_course course_provider_a
      audit = create(
        :application_form_audit,
        application_choice: choice,
        changes: {
          'date_of_birth' => %w[Hello Hi],
          'first_name' => %w[Hello Hi],
          'last_name' => %w[Hello Hi],
          'phone_number' => %w[Hello Hi],
          'address_line1' => %w[Hello Hi],
          'address_line2' => %w[Hello Hi],
          'address_line3' => %w[Hello Hi],
          'address_line4' => %w[Hello Hi],
          'country' => %w[Hello Hi],
          'postcode' => %w[Hello Hi],
          'region_code' => %w[Hello Hi],
          'interview_preferences' => %w[Hello Hi],
          'disability_disclosure' => %w[Hello Hi],
        },
      )

      result = service_call

      expect(result).to include(audit)
    end

    it 'includes application_choice events with a status change' do
      choice = create_application_choice_for_course course_provider_a

      excluded = create(
        :application_choice_audit,
        application_choice: choice,
        changes: { 'reject_by_default_at' => [nil, 40.days.from_now.iso8601] },
      )

      included = create(
        :application_choice_audit,
        application_choice: choice,
        changes: { 'status' => %w[awaiting_provider_decision offer] },
      )

      result = service_call

      expect(result).not_to include(excluded)
      expect(result).to include(included)
    end

    it 'includes events with a reject_by_default_feedback_sent_at change' do
      choice = create_application_choice_for_course course_provider_a

      excluded = create(
        :application_choice_audit,
        application_choice: choice,
        changes: { 'reject_by_default_at' => [nil, 40.days.from_now.iso8601] },
      )

      included = create(
        :application_choice_audit,
        application_choice: choice,
        changes: { 'reject_by_default_feedback_sent_at' => [nil, Time.zone.now.iso8601] },
      )

      result = service_call

      expect(result).not_to include(excluded)
      expect(result).to include(included)
    end

    it 'includes only status change events visible to providers' do
      choice = create_application_choice_for_course course_provider_a

      excluded = create(
        :application_choice_audit,
        application_choice: choice,
        changes: { 'status' => %w[awaiting_references application_complete] },
      )

      included = create(
        :application_choice_audit,
        application_choice: choice,
        changes: { 'status' => %w[status_not_visible_to_providers awaiting_provider_decision] },
      )

      result = service_call

      expect(result).not_to include(excluded)
      expect(result).to include(included)
    end

    it 'excludes audits for OfferConditions' do
      choice = create_application_choice_for_course course_provider_a

      offer = create(:offer, application_choice: choice)
      offer.conditions.first.update!(status: :met)

      excluded = offer.conditions.first.audits.last

      result = service_call

      expect(result).not_to include(excluded)
    end

    it 'excludes audits for ApplicationExperience and ApplicationWorkHistoryBreak' do
      choice = create_application_choice_for_course course_provider_a
      work_experience = create(:application_work_experience, experienceable: choice)
      work_history_break = create(:application_work_history_break, breakable: choice)
      create(
        :application_experience_audit,
        application_experience: work_experience,
        application_choice: choice,
      )
      create(
        :application_work_history_break_audit,
        application_work_history_break: work_history_break,
        application_choice: choice,
      )

      work_experience_audit = work_experience.audits.last
      work_break_audit = work_history_break.audits.last

      result = service_call

      expect(result).not_to include(work_experience_audit, work_break_audit)
    end
  end

  context 'sorts events in reverse chronological order' do
    it 'within an application' do
      choice = create_application_choice_for_course(course_provider_a)
      audits = 3.times.map do
        TestSuiteTimeMachine.advance
        create_audit_for_application_choice(choice)
      end

      expect(service_call.map(&:id)).to eq(audits.reverse.map(&:id))
    end

    it 'across applications and providers' do
      choice_a = create_application_choice_for_course(course_provider_a)
      choice_b = create_application_choice_for_course(course_provider_b)

      audits = 5.times.map do
        TestSuiteTimeMachine.advance
        create_audit_for_application_choice([choice_a, choice_b].sample)
      end

      expect(service_call.map(&:id)).to eq(audits.reverse.map(&:id))
    end
  end

  context 'completes in a reasonable timeframe' do
    it '<50ms for 1000 application choices' do
      skip 'This spec takes a long time and should be run manually'

      TestSuiteTimeMachine.revert_to_real_world_time

      1000.times do
        %i[course_provider_a course_provider_b course_unrelated ratified_course_provider_b ratified_course_unrelated].each do |course|
          choice = create_application_choice_for_course send(course)
          20.times.map { create_audit_for_application_choice choice }
        end
      end

      elapsed_time = Benchmark.measure { service_call }.real
      logger.info "GetProviderActivityLogEvents #call completed in #{elapsed_time}s"

      expect(elapsed_time).to be < 0.05
    end
  end

  context 'with interviews associated to applications' do
    let(:application_choice) { create(:application_choice, :interviewing) }

    it 'returns events associated with interviews' do
      result = described_class.call(application_choices: ApplicationChoice.where(id: application_choice.id))

      expect(result.first.auditable).to eq(application_choice.interviews.first)
      expect(result.first.associated).to eq(application_choice)
    end
  end

  context 'with a cancelled interview' do
    let(:application_choice) { create(:application_choice, :interviewing) }
    let(:auth) { instance_double(ProviderAuthorisation, assert_can_set_up_interviews!: true) }

    before do
      allow(ProviderAuthorisation).to receive(:new).and_return(auth)
      allow(auth).to receive(:actor).and_return(provider_user)
      CancelInterview.new(
        actor: provider_user,
        application_choice:,
        interview: application_choice.interviews.first,
        cancellation_reason: 'test',
      ).save!
    end

    it 'filters out the status transition for an application choice when cancelling an interview' do
      excluded = Audited::Audit.where(
        auditable: application_choice,
        audited_changes: { status: %w[interviewing awaiting_provider_decision] },
      )
      result = described_class.call(application_choices: ApplicationChoice.where(id: application_choice.id))

      expect(excluded).to exist
      expect(result).not_to include(excluded)
    end
  end
end
