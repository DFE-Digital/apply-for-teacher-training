require 'rails_helper'

RSpec.describe TestApplications do
  it 'generates an application with choices in the given states' do
    create(:course_option, course: create(:course, :open_on_apply))
    create(:course_option, course: create(:course, :open_on_apply))

    choices = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[offer rejected], courses_to_apply_to: Course.all)

    expect(choices.count).to eq(2)
  end

  it 'creates a realistic timeline for a recruited application' do
    courses_we_want = create_list(:course_option, 2, course: create(:course, :open_on_apply)).map(&:course)

    application_choice = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[recruited], courses_to_apply_to: courses_we_want).first

    application_form = application_choice.application_form
    candidate = application_form.candidate

    expect(candidate.created_at).to eq candidate.last_signed_in_at
    expect(candidate.created_at <= application_choice.created_at).to be true
    expect(application_choice.created_at <= application_form.submitted_at).to be true
    expect(application_choice.sent_to_provider_at <= application_choice.offered_at).to be true
    expect(application_choice.offered_at <= application_choice.accepted_at).to be true
  end

  it 'creates a realistic timeline for an offered application' do
    courses_we_want = create_list(:course_option, 2, course: create(:course, :open_on_apply)).map(&:course)

    application_choice = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[offer], courses_to_apply_to: courses_we_want).first

    application_form = application_choice.application_form
    candidate = application_form.candidate
    expect(candidate.created_at <= application_choice.created_at).to be true
    expect(application_choice.created_at <= application_form.submitted_at).to be true
    expect(application_choice.sent_to_provider_at <= application_choice.offered_at).to be true
  end

  it 'changes the course to a valid one if the offer is changed' do
    provider = create(:provider)
    ratifying_provider = create(:provider)

    course_to_make_original_offer_for = create(:course_option, course: create(:course, :open_on_apply, provider: provider, accredited_provider: ratifying_provider)).course
    create(:course_option, course: create(:course, :open_on_apply, provider: provider, accredited_provider: ratifying_provider)).course
    create(:course_option, course: create(:course, :open_on_apply, provider: provider))

    application_choice = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[offer_changed], courses_to_apply_to: [course_to_make_original_offer_for]).first

    expect(application_choice.current_course.ratifying_provider).to eq(ratifying_provider)
  end

  it 'attributes actions to candidates', with_audited: true do
    courses_we_want = create_list(:course_option, 1, course: create(:course, :open_on_apply)).map(&:course)

    application_choice = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[recruited], courses_to_apply_to: courses_we_want).first
    application_form = application_choice.application_form
    candidate = application_form.candidate

    submission_audit = application_choice.audits.where("audited_changes @> '{\"status\": [\"unsubmitted\", \"awaiting_provider_decision\"]}'").first
    expect(submission_audit).not_to be_nil
    expect(submission_audit.user).to eq candidate
  end

  it 'attributes actions to provider users', with_audited: true do
    courses_we_want = create_list(:course_option, 1, course: create(:course, :open_on_apply)).map(&:course)

    application_choice = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[recruited], courses_to_apply_to: courses_we_want).first
    provider_user = application_choice.provider.provider_users.first

    recruited_audit = application_choice.reload.audits.where("audited_changes @> '{\"status\": [\"recruited\"]}'").first
    expect(recruited_audit).not_to be_nil
    expect(recruited_audit.user).to eq provider_user
  end

  it 'generates an application for the specified candidate' do
    expected_candidate = create(:candidate)
    courses_we_want = create_list(:course_option, 2, course: create(:course, :open_on_apply)).map(&:course)

    application_choice = described_class.new.create_application(
      recruitment_cycle_year: 2021,
      states: %i[unsubmitted_with_completed_references],
      courses_to_apply_to: courses_we_want,
      candidate: expected_candidate,
    ).first

    candidate = application_choice.application_form.candidate

    expect(candidate).to eq expected_candidate
  end

  it 'throws an exception if there are not enough courses to apply to' do
    expect {
      described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[offer], courses_to_apply_to: [])
    }.to raise_error(/Not enough distinct courses/)
  end

  it 'throws an exception if zero courses are specified per application' do
    expect {
      described_class.new.create_application(recruitment_cycle_year: 2020, states: [], courses_to_apply_to: [])
    }.to raise_error(/You cannot have zero courses per application/)
  end

  describe 'supplying our own courses' do
    it 'creates applications only for the supplied courses' do
      course_we_want = create(:course_option, course: create(:course, :open_on_apply)).course

      choices = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[offer], courses_to_apply_to: [course_we_want])

      expect(choices.first.course).to eq(course_we_want)
    end

    it 'creates the right number of applications' do
      courses_we_want = create_list(:course_option, 2, course: create(:course, :open_on_apply)).map(&:course)

      choices = described_class.new.create_application(recruitment_cycle_year: 2020, states: %i[offer], courses_to_apply_to: courses_we_want)

      expect(choices.count).to eq(1)
    end
  end

  describe 'full work history' do
    it 'creates applications with work experience as well as explained and unexplained breaks' do
      create(:course_option, course: create(:course, :open_on_apply))

      choices = described_class.new.create_application(recruitment_cycle_year: 2020, courses_to_apply_to: Course.all, states: %i[awaiting_provider_decision])

      expect(choices.count).to eq(1)
      expect(choices.first.application_form.application_work_experiences.count).to eq(2)
      expect(choices.first.application_form.application_work_history_breaks.count).to eq(1)
    end
  end

  describe 'reference completion' do
    let(:courses_we_want) do
      create_list(:course_option, 2, course: create(:course, :open_on_apply)).map(&:course)
    end

    let(:application_choice) do
      described_class.new.create_application(
        recruitment_cycle_year: 2021,
        states: application_states,
        courses_to_apply_to: courses_we_want,
        incomplete_references: incomplete_references,
      ).first
    end

    let(:references) { application_choice.application_form.application_references }
    let(:incomplete_references) { false }

    subject { references.map(&:feedback_status) }

    describe 'generating a representative collection of references' do
      let(:application_states) { %i[awaiting_provider_decision] }
      let(:expected) do
        %w[not_requested_yet feedback_refused feedback_provided feedback_provided cancelled]
      end

      it { is_expected.to match_array(expected) }
    end

    describe 'does not complete any references for unsubmitted applications' do
      let(:application_states) { %i[unsubmitted] }
      let(:expected) do
        %w[not_requested_yet feedback_requested feedback_requested feedback_requested feedback_requested]
      end

      it { is_expected.to match_array(expected) }
    end

    describe 'return only incomplete references' do
      let(:incomplete_references) { true }

      let(:application_states) { %i[awaiting_provider_decision] }
      let(:expected) do
        ['not_requested_yet'] * 5
      end

      it { is_expected.to match_array(expected) }

      describe 'all references marked as selected' do
        subject { references.pluck(:selected).uniq }

        it { is_expected.to eq [true] }
      end
    end
  end

  describe 'scheduled interview' do
    it 'generates an interview for application choices in the interviewing state' do
      courses_we_want = create_list(:course_option, 2, course: create(:course, :open_on_apply)).map(&:course)

      application_choice = described_class.new.create_application(recruitment_cycle_year: 2021, states: %i[interviewing], courses_to_apply_to: courses_we_want).first

      expect(application_choice.interviews.count).to eq(1)
    end
  end

  describe 'apply again' do
    it 'generates 2 applications, one in the past and one current' do
      create(:course_option, course: create(:course, :open_on_apply))
      described_class.new.create_application(recruitment_cycle_year: RecruitmentCycle.current_year, states: %i[awaiting_provider_decision], courses_to_apply_to: Course.current_cycle, apply_again: true)
      previous_form = ApplicationForm.first
      new_form = ApplicationForm.last

      expect(previous_form).not_to be_nil
      expect(previous_form.created_at).to be_between(30.days.ago.beginning_of_day, 21.days.ago.beginning_of_day)
      expect(new_form).not_to be_nil
      expect(new_form.created_at).to be_between(20.days.ago.beginning_of_day, Time.zone.now)
    end
  end

  describe 'carried over' do
    it 'generates an application to courses from the year before' do
      create(:course_option, course: create(:course, :open_on_apply))
      create(:course_option, course: create(:course, :open_on_apply, :previous_year))

      described_class.new.create_application(recruitment_cycle_year: RecruitmentCycle.current_year, states: %i[awaiting_provider_decision], courses_to_apply_to: Course.current_cycle, carry_over: true)

      previous_form = ApplicationForm.where(recruitment_cycle_year: RecruitmentCycle.previous_year).first
      new_form = ApplicationForm.current_cycle.first

      expect(previous_form).not_to be_nil
      expect(previous_form.application_choices.first.course.recruitment_cycle_year).to eq(RecruitmentCycle.previous_year)
      expect(new_form).not_to be_nil
      expect(new_form.application_choices.first.course.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
    end
  end

  it 'marks any submitted application choices as just updated', with_audited: true do
    create(:course_option, course: create(:course, :open_on_apply))

    choices = described_class.new.create_application(recruitment_cycle_year: 2020, courses_to_apply_to: Course.all, states: %i[awaiting_provider_decision])

    expect(choices.count).to eq(1)
    expect(choices.first.reload.updated_at).to be_within(1.second).of(Time.zone.now)
    expect(choices.first.audits.last.comment).to eq('This application was automatically generated')
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
        expect(equality_and_diversity['hesa_sex']).to eq(Hesa::Sex.find(equality_and_diversity['sex'])['hesa_code'])
      end
    end

    it 'assigns the correct hesa code for ethnicity' do
      expect(equality_and_diversity['hesa_ethnicity']).to eq(Hesa::Ethnicity.find(equality_and_diversity['ethnic_background'], 2021)['hesa_code'])
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
