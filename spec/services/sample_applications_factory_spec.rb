require 'rails_helper'

RSpec.describe SampleApplicationsFactory do
  it 'generates an application with choices in the given states' do
    create(:course_option, course: create(:course, :open))
    create(:course_option, course: create(:course, :open))

    choices = described_class.create_application(
      states: %i[offer rejected],
      courses_to_apply_to: Course.all,
    )

    expect(choices.count).to eq(2)
    expect(choices.map(&:status)).to match_array(%w[offer rejected])
  end

  it 'creates a realistic timeline for a recruited application' do
    courses_we_want = create_list(:course_option, 2, course: create(:course, :open)).map(&:course)

    application_choice = described_class.create_application(
      states: %i[recruited],
      courses_to_apply_to: courses_we_want,
    ).first

    application_form = application_choice.application_form
    candidate = application_form.candidate

    expect(candidate.created_at).to eq candidate.last_signed_in_at
    expect(candidate.created_at <= application_choice.created_at).to be true
    expect(application_choice.created_at <= application_form.submitted_at).to be true
    expect(application_choice.sent_to_provider_at <= application_choice.offered_at).to be true
    expect(application_choice.offered_at <= application_choice.accepted_at).to be true
    expect(application_choice.accepted_at <= application_choice.recruited_at).to be true
  end

  it 'creates a realistic timeline for an offered application' do
    courses_we_want = create_list(:course_option, 2, course: create(:course, :open)).map(&:course)

    application_choice = described_class.create_application(
      states: %i[offer],
      courses_to_apply_to: courses_we_want,
    ).first

    application_form = application_choice.application_form
    candidate = application_form.candidate
    expect(candidate.created_at <= application_choice.created_at).to be true
    expect(application_choice.created_at <= application_form.submitted_at).to be true
    expect(application_choice.sent_to_provider_at <= application_choice.offered_at).to be true
  end

  it 'changes the course to a valid one if the offer is changed' do
    provider = create(:provider)
    ratifying_provider = create(:provider)

    course_to_make_original_offer_for = create(:course_option, course: create(:course, :open, provider:, accredited_provider: ratifying_provider)).course
    create(:course_option, course: create(:course, :open, provider:, accredited_provider: ratifying_provider)).course
    create(:course_option, course: create(:course, :open, provider:))

    application_choice = described_class.create_application(
      states: %i[course_changed_after_offer],
      courses_to_apply_to: [course_to_make_original_offer_for],
    ).first

    expect(application_choice.current_course.ratifying_provider).to eq(ratifying_provider)
  end

  it 'generates an application for the specified candidate' do
    expected_candidate = create(:candidate)
    courses_we_want = create_list(:course_option, 2, course: create(:course, :open)).map(&:course)

    application_choice = described_class.create_application(
      states: %i[unsubmitted],
      courses_to_apply_to: courses_we_want,
      candidate: expected_candidate,
    ).first

    candidate = application_choice.application_form.candidate

    expect(candidate).to eq expected_candidate
  end

  it 'throws an exception if there are not enough courses to apply to' do
    expect {
      described_class.create_application(states: %i[offer], courses_to_apply_to: [])
    }.to raise_error(/must have at least as many courses/)
  end

  it 'throws an exception if zero courses are specified per application' do
    expect {
      described_class.create_application(states: [], courses_to_apply_to: [])
    }.to raise_error(/must be an array of at least one state/)
  end

  describe 'supplying our own courses' do
    it 'creates applications only for the supplied courses' do
      course_we_want = create(:course_option, course: create(:course, :open)).course

      choices = described_class.create_application(states: %i[offer], courses_to_apply_to: [course_we_want])

      expect(choices.first.course).to eq(course_we_want)
    end

    it 'creates the right number of applications' do
      courses_we_want = create_list(:course_option, 2, course: create(:course, :open)).map(&:course)

      choices = described_class.create_application(states: %i[offer], courses_to_apply_to: courses_we_want)

      expect(choices.count).to eq(1)
    end
  end

  describe 'full work history' do
    it 'creates applications with work experience as well as explained and unexplained breaks' do
      create(:course_option, course: create(:course, :open))

      choices = described_class.create_application(courses_to_apply_to: Course.all, states: %i[awaiting_provider_decision])

      expect(choices.count).to eq(1)
      expect(choices.first.application_form.application_work_experiences.count).to eq(2)
      expect(choices.first.application_form.application_work_history_breaks.count).to eq(1)
    end
  end

  describe 'reference completion' do
    let(:courses_we_want) do
      create_list(:course_option, 2, course: create(:course, :open)).map(&:course)
    end

    let(:application_choice) do
      described_class.create_application(
        states: application_states,
        courses_to_apply_to: courses_we_want,
      ).first
    end

    let(:references) { application_choice.application_form.application_references.creation_order }

    subject { references.map(&:feedback_status) }

    describe 'generating a representative collection of requested references' do
      let(:application_states) { %i[accepted] }
      let(:expected) do
        %w[feedback_requested feedback_requested]
      end

      it { is_expected.to match_array(expected) }
    end

    describe 'does not complete any references for unsubmitted applications' do
      let(:application_states) { %i[unsubmitted] }
      let(:expected) do
        %w[not_requested_yet not_requested_yet]
      end

      it { is_expected.to match_array(expected) }
    end

    describe 'completes references for recruited applications' do
      let(:application_states) { %i[recruited] }
      let(:expected) do
        %w[feedback_provided feedback_provided]
      end

      it { is_expected.to match_array(expected) }
    end
  end

  describe 'scheduled interview' do
    context 'when between reject by default and find reopens', time: after_reject_by_default do
      it 'does not generate an interview' do
        courses_we_want = create_list(:course_option, 2, course: create(:course, :open)).map(&:course)

        application_choice = described_class.create_application(
          states: %i[interviewing],
          courses_to_apply_to: courses_we_want,
        ).first

        expect(application_choice.status).to eq('awaiting_provider_decision')
        expect(application_choice.interviews.count).to eq(0)
      end
    end

    context 'when after find reopens', time: after_find_reopens do
      it 'generates an interview for application choices in the interviewing state' do
        courses_we_want = create_list(:course_option, 2, course: create(:course, :open)).map(&:course)

        application_choice = described_class.create_application(
          states: %i[interviewing],
          courses_to_apply_to: courses_we_want,
        ).first

        expect(application_choice.status).to eq('interviewing')
        expect(application_choice.interviews.count).to eq(1)
      end
    end
  end

  describe 'apply again' do
    it 'generates 2 applications, one in the past and one current' do
      create(:course_option, course: create(:course, :open))
      described_class.create_application(recruitment_cycle_year: RecruitmentCycle.current_year, states: %i[awaiting_provider_decision], courses_to_apply_to: Course.current_cycle, apply_again: true)
      new_form = ApplicationForm.last
      previous_form = new_form.previous_application_form

      expect(previous_form).not_to be_nil
      expect(previous_form.created_at).to be_between(CycleTimetable.apply_opens, CycleTimetable.apply_1_deadline)
      expect(previous_form.phase).to eq('apply_1')
      expect(new_form).not_to be_nil
      expect(new_form.created_at).to be_between(CycleTimetable.apply_1_deadline, CycleTimetable.apply_2_deadline)
      expect(new_form.phase).to eq('apply_2')
    end
  end

  describe 'carried over' do
    it 'raises error if apply again is true' do
      create(:course_option, course: create(:course, :open))

      expect {
        described_class.create_application(
          states: %i[awaiting_provider_decision],
          courses_to_apply_to: Course.current_cycle,
          carry_over: true,
          apply_again: true,
        )
      }.to raise_error(ArgumentError, 'Cannot set both carry_over and apply_again to true')
    end

    it 'generates an application to courses from the year before' do
      create(:course_option, course: create(:course, :open))

      described_class.create_application(states: %i[awaiting_provider_decision], courses_to_apply_to: Course.current_cycle, carry_over: true)

      previous_form = ApplicationForm.where(recruitment_cycle_year: RecruitmentCycle.previous_year).first
      new_form = ApplicationForm.current_cycle.first

      expect(previous_form).not_to be_nil
      expect(previous_form.application_choices.first.course.recruitment_cycle_year).to eq(RecruitmentCycle.previous_year)
      expect(new_form).not_to be_nil
      expect(new_form.application_choices.first.course.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
    end
  end

  it 'marks any submitted application choices as just updated' do
    create(:course_option, course: create(:course, :open_on_apply))

    choices = described_class.create_application(
      courses_to_apply_to: Course.all,
      states: %i[awaiting_provider_decision],
    )

    expect(choices.count).to eq(1)
    expect(choices.first.reload.updated_at).to be_within(1.second).of(Time.zone.now)
  end

  context 'with equality and diversity information' do
    # TestApplications relies on the ApplicationForm factory trait :with_equality_and_diversity_data to generate
    # equality_and_diversity attributes, we don't need to test a generated app here, just the factory code pairing logic.
    let(:application_form) do
      create(:application_form, :with_equality_and_diversity_data)
    end

    let(:equality_and_diversity) { application_form.equality_and_diversity }

    it 'assigns the correct hesa code for sex' do
      if equality_and_diversity['sex'] == 'Prefer not to say'
        expect(equality_and_diversity['hesa_sex']).to be_nil
      else
        expect(equality_and_diversity['hesa_sex']).to eq(
          Hesa::Sex.find(equality_and_diversity['sex'], RecruitmentCycle.current_year)['hesa_code'],
        )
      end
    end

    it 'assigns the correct hesa code for ethnicity' do
      expect(equality_and_diversity['hesa_ethnicity']).to eq(Hesa::Ethnicity.find(equality_and_diversity['ethnic_background'], RecruitmentCycle.current_year)['hesa_code'])
    end

    it 'assigns the correct hesa codes for disabilities' do
      if equality_and_diversity['disabilities'] == ['Prefer not to say']
        expect(equality_and_diversity['hesa_disabilities']).to eq(%w[00])
      else
        expected = equality_and_diversity['disabilities'].map { |d| Hesa::Disability.find(d)['hesa_code'] }
        expect(equality_and_diversity['hesa_disabilities']).to eq(expected)
      end
    end
  end
end
