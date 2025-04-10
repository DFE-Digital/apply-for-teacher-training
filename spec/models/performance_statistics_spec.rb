require 'rails_helper'

RSpec.describe PerformanceStatistics do
  include CourseOptionHelpers

  describe '#[]' do
    it 'does not count candidates without application forms' do
      create(:candidate)

      expect(ApplicationFormStateInferrer.new(nil).state).to be :never_signed_in

      expect(count_for_state_inferrer(:never_signed_in)).to be(0)
    end

    it 'counts unsubmitted and unstarted applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      form = application_choice.application_form
      form.update_column(:updated_at, form.created_at)

      expect(ApplicationFormStateInferrer.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_state_inferrer(:unsubmitted_not_started_form)).to be(1)
    end

    it 'counts application_not_sent applications as unsubmitted_in_progress' do
      application_choice = create(:application_choice, status: 'application_not_sent')
      form = application_choice.application_form

      # applications are considered in progress if updated_at != created_at
      form.update_column(:updated_at, form.created_at + 6.hours)

      expect(ApplicationFormStateInferrer.new(form).state).to be :unsubmitted_in_progress

      expect(count_for_state_inferrer(:unsubmitted_in_progress)).to be(1)
    end

    it 'counts unsubmitted, unstarted applications from both phases' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      form = application_choice.application_form
      form.update_column(:updated_at, form.created_at)

      apply_again_form = create(:application_form, phase: 'apply_2')
      create(:application_choice, status: 'unsubmitted', application_form: apply_again_form)
      apply_again_form.update_column(:updated_at, apply_again_form.created_at)

      expect(ApplicationFormStateInferrer.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_state_inferrer(:unsubmitted_not_started_form)).to be(2)
    end

    it 'counts unsubmitted, unstarted applications without choices' do
      form = create(:application_form)

      expect(ApplicationFormStateInferrer.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_state_inferrer(:unsubmitted_not_started_form)).to be(1)
    end

    it 'counts unsubmitted, started applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      application_choice.application_form.update_column(:updated_at, 1.day.from_now)

      expect(ApplicationFormStateInferrer.new(application_choice.application_form).state).to be :unsubmitted_in_progress

      expect(count_for_state_inferrer(:unsubmitted_in_progress)).to be(1)
    end

    it 'counts applications awaiting a provider decision' do
      application_choice = create(:application_choice, status: 'awaiting_provider_decision')
      create(:application_choice, application_form: application_choice.application_form, status: 'offer')

      expect(ApplicationFormStateInferrer.new(application_choice.application_form).state).to be :awaiting_provider_decisions

      expect(count_for_state_inferrer(:awaiting_provider_decisions)).to be(1)
    end

    it 'counts applications with offers' do
      form = create(:application_form)
      create_list(:application_choice, 2, application_form: form, status: 'offer')

      expect(ApplicationFormStateInferrer.new(form).state).to be :awaiting_candidate_response

      expect(count_for_state_inferrer(:awaiting_candidate_response)).to be(1)
    end

    it 'counts recruited applications' do
      application_choice = create(:application_choice, status: 'recruited')

      expect(ApplicationFormStateInferrer.new(application_choice.application_form).state).to be :recruited

      expect(count_for_state_inferrer(:recruited)).to be(1)
    end

    it 'counts applications pending conditions' do
      application_choice = create(:application_choice, status: 'pending_conditions')

      expect(ApplicationFormStateInferrer.new(application_choice.application_form).state).to be :pending_conditions

      expect(count_for_state_inferrer(:pending_conditions)).to be(1)
    end

    it 'counts applications that ended without success' do
      withdrawn_form, rejected_form, declined_form, conditions_not_met_form = create_list(:application_form, 4)
      create_list(:application_choice, 2, application_form: withdrawn_form, status: 'withdrawn')
      create_list(:application_choice, 2, application_form: rejected_form, status: 'rejected')
      create_list(:application_choice, 2, application_form: declined_form, status: 'declined')
      create_list(:application_choice, 2, application_form: conditions_not_met_form, status: 'conditions_not_met')
      expect(ApplicationFormStateInferrer.new(withdrawn_form).state).to be :ended_without_success
      expect(ApplicationFormStateInferrer.new(rejected_form).state).to be :ended_without_success
      expect(ApplicationFormStateInferrer.new(declined_form).state).to be :ended_without_success
      expect(ApplicationFormStateInferrer.new(conditions_not_met_form).state).to be :ended_without_success
      expect(count_for_state_inferrer(:ended_without_success)).to be(4)
    end
  end

  describe '#candidate_count' do
    it 'returns the total number of candidates that were created during a given cycle' do
      timetable = get_timetable(2023)
      travel_temporarily_to(timetable.find_opens_at + 1.day) do
        create_list(:candidate, 2)
      end
      travel_temporarily_to(timetable.apply_deadline_at + 1.day) do
        create_list(:candidate, 3)
      end

      expect(described_class.new(2023).candidate_count).to eq(2)
      expect(described_class.new(2024).candidate_count).to eq(3)
    end

    it 'returns the total number of candidates that exist when no cycle is given' do
      travel_temporarily_to(2023, 1, 5) do
        create_list(:candidate, 2)
      end
      travel_temporarily_to(2023, 12, 25) do
        create_list(:candidate, 3)
      end

      expect(described_class.new(nil).candidate_count).to eq(5)
    end

    it 'does not take into account any application forms that a candidate may have' do
      travel_temporarily_to(2023, 1, 5) do
        create(:application_form, recruitment_cycle_year: 2024)
      end

      expect(described_class.new(2023).candidate_count).to eq(1)
      expect(described_class.new(2024).candidate_count).to eq(0)
    end
  end

  describe '#total_form_count' do
    it 'optionally filters only on certain process states and excludes certain states' do
      create(:application_choice, status: 'recruited')
      create(:application_choice, status: 'recruited')
      create(:application_choice, status: 'pending_conditions')

      stats = described_class.new(nil)

      expect(stats.total_form_count(only: %i[recruited])).to eq(2)
      expect(stats.total_form_count(except: %i[pending_conditions])).to eq(2)
    end

    it 'optionally filters by phase' do
      apply_1_form = create(:application_form, phase: 'apply_1')
      apply_2_form = create(:application_form, phase: 'apply_2')
      create(:application_choice, status: 'recruited', application_form: apply_1_form)
      create(:application_choice, status: 'recruited', application_form: apply_2_form)
      create(:application_choice, status: 'pending_conditions')
      create(:candidate)

      stats = described_class.new(nil)

      expect(stats.total_form_count(only: %i[recruited])).to eq(2)
      expect(stats.total_form_count(only: %i[recruited], phase: :apply_1)).to eq(1)
      expect(stats.total_form_count(only: %i[recruited], phase: :apply_2)).to eq(1)
      expect(stats.total_form_count(phase: :apply_2)).to eq(1)
      expect(stats.total_form_count(except: %i[pending_conditions])).to eq(2)
    end
  end

  describe '#initialize' do
    it 'can filter by year' do
      create(:application_choice, status: 'recruited', application_form: create(:application_form, recruitment_cycle_year: 2020))
      create(:application_choice, status: 'recruited', application_form: create(:application_form, recruitment_cycle_year: 2021))

      stats = described_class.new(2021)

      expect(stats.total_form_count).to eq(1)
    end
  end

  describe '#percentage_of_providers_onboarded' do
    it 'returns the percentage of providers onboarded to the nearest whole number' do
      create(:provider)
      synced_providers = create_list(:provider, 2)
      create_list(:course, 3, provider: synced_providers.first)

      stats = described_class.new(2021)

      expect(stats.percentage_of_providers_onboarded).to eq('33%')
    end

    it 'returns "-" when there are no providers' do
      stats = described_class.new(2021)

      expect(stats.percentage_of_providers_onboarded).to eq('-')
    end
  end

  describe '#rejected_by_default_count' do
    it 'returns the count of all rejected by default applications' do
      create(:application_choice, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2020))
      create_list(:application_choice, 2, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:application_choice, status: 'rejected', rejected_by_default: false, application_form: create(:application_form, recruitment_cycle_year: 2021))

      stats = described_class.new(nil)

      expect(stats.rejected_by_default_count).to eq(2)
    end

    it 'returns the count of all rejected by default applications filtered by recruitment cycle year' do
      create(:application_choice, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2020))
      create_list(:application_choice, 2, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:application_choice, status: 'rejected', rejected_by_default: false, application_form: create(:application_form, recruitment_cycle_year: 2021))

      stats = described_class.new(2021)

      expect(stats.rejected_by_default_count).to eq(1)
    end
  end

  describe '#withdrawn_at_candidates_request_count and #withdrawn_by_candidate_count' do
    let(:declined_choice) { create(:application_choice, :declined, application_form: create(:application_form, recruitment_cycle_year: 2021)) }
    let(:withdrawn_choice) { create(:application_choice, :withdrawn, application_form: create(:application_form, recruitment_cycle_year: 2021)) }
    let!(:choice_withdrawn_by_candidate) { create(:application_choice, :withdrawn, application_form: create(:application_form, recruitment_cycle_year: 2021)) }
    let!(:declined_audit) do
      create(
        :withdrawn_at_candidates_request_audit,
        application_choice: declined_choice,
        comment: 'Declined on behalf of the candidate',
      )
    end
    let!(:withdrawn_audit) { create(:withdrawn_at_candidates_request_audit, application_choice: withdrawn_choice) }

    it '#withdrawn_at_candidates_request_count returns a count of applications which have been declined or withdrawn at the candidates request' do
      stats = described_class.new(2021)

      expect(stats.withdrawn_at_candidates_request_count).to eq(2)
    end

    it '#withdrawn_by_candidate_count returns a count of applications which have been declined or withdrawn by the candidate' do
      stats = described_class.new(2021)

      expect(stats.withdrawn_by_candidate_count).to eq(1)
    end
  end

  def count_for_state_inferrer(state_inferrer)
    described_class.new(nil)[state_inferrer]
  end

  it 'excludes candidates marked as hidden from reporting' do
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    visible_candidate = create(:candidate, hide_in_reporting: false)
    create(:application_form, candidate: hidden_candidate)
    create(:application_form, candidate: visible_candidate)

    stats = described_class.new(nil)

    expect(stats.total_form_count).to eq(1)
  end

  describe '#total_application_choice_count' do
    it 'returns the total number of application choices, respecting the cycle' do
      create(:application_choice, :awaiting_provider_decision, application_form: create(:application_form, recruitment_cycle_year: 2020))
      create(:application_choice, :awaiting_provider_decision, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:application_choice, :unsubmitted, application_form: create(:application_form, recruitment_cycle_year: 2019)) # should not be counted bc unsubmitted

      expect(described_class.new(2021).total_application_choice_count).to eq 1
      expect(described_class.new(2020).total_application_choice_count).to eq 1

      expect(described_class.new(nil).total_application_choice_count).to eq 2
    end

    it 'does not include candidates excluded from the performance data' do
      candidate = create(:candidate, hide_in_reporting: true)
      application_form = create(:completed_application_form, candidate:)
      create(:application_choice, :awaiting_provider_decision, application_form:)

      expect(described_class.new(nil).total_application_choice_count).to eq 0
    end
  end

  describe '#application_choices_by_provider_type' do
    it 'returns a hash of provider_type => count' do
      hei = create(:provider, provider_type: 'university')
      scitt = create(:provider, provider_type: 'scitt')
      sd = create(:provider, provider_type: 'lead_school')

      hei_course_2020 = course_option_for_provider(provider: hei, recruitment_cycle_year: 2020)
      hei_course_2021 = course_option_for_provider(provider: hei, recruitment_cycle_year: 2021)
      _hei_app_2020 = create(:application_choice, :awaiting_provider_decision,
                             course_option: hei_course_2020,
                             application_form: create(:application_form, recruitment_cycle_year: 2020))
      _hei_app_2021 = create(:application_choice, :awaiting_provider_decision,
                             course_option: hei_course_2021,
                             application_form: create(:application_form, recruitment_cycle_year: 2021))

      scitt_course_2020 = course_option_for_provider(provider: scitt, recruitment_cycle_year: 2020)
      scitt_course_2021 = course_option_for_provider(provider: scitt, recruitment_cycle_year: 2021)
      _scitt_app_2020 = create(:application_choice, :awaiting_provider_decision,
                               course_option: scitt_course_2020,
                               application_form: create(:application_form, recruitment_cycle_year: 2020))
      _scitt_app_2021 = create(:application_choice, :awaiting_provider_decision,
                               course_option: scitt_course_2021,
                               application_form: create(:application_form, recruitment_cycle_year: 2021))
      _scitt_app_2021 = create(:application_choice, :unsubmitted,
                               course_option: scitt_course_2021,
                               application_form: create(:application_form, recruitment_cycle_year: 2021))

      # no SD app in 2020
      # two 20201 applications ratified by HEI and SCITT respectively
      sd_hei_course_2021 = course_option_for_accredited_provider(provider: sd, accredited_provider: hei, recruitment_cycle_year: 2021)
      sd_scitt_course_2021 = course_option_for_accredited_provider(provider: sd, accredited_provider: scitt, recruitment_cycle_year: 2021)
      _sd_hei_app_2021 = create(:application_choice, :awaiting_provider_decision,
                                course_option: sd_hei_course_2021,
                                application_form: create(:application_form, recruitment_cycle_year: 2021))
      _sd_scitt_app_2021 = create(:application_choice, :awaiting_provider_decision,
                                  course_option: sd_scitt_course_2021,
                                  application_form: create(:application_form, recruitment_cycle_year: 2021))

      expect(described_class.new(2021).application_choices_by_provider_type).to eq({
        'scitt' => 1,
        'university' => 1,
        'lead_school' => 2,
        'ratified_by_scitt' => 1,
        'ratified_by_university' => 1,
      })
      expect(described_class.new(2020).application_choices_by_provider_type).to eq({
        'scitt' => 1,
        'university' => 1,
        'lead_school' => 0,
        'ratified_by_scitt' => 0,
        'ratified_by_university' => 0,
      })
      expect(described_class.new(nil).application_choices_by_provider_type).to eq({
        'scitt' => 2,
        'university' => 2,
        'lead_school' => 2,
        'ratified_by_scitt' => 1,
        'ratified_by_university' => 1,
      })
    end
  end
end
