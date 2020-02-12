require 'rails_helper'

RSpec.describe PerformanceStatistics, type: :model do
  describe '#candidate_status_counts' do
    it 'counts unsubmitted, unstarted applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      form = application_choice.application_form
      form.update_column(:updated_at, form.created_at)

      expect(ProcessState.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_process_state(:unsubmitted_not_started_form)).to be(1)
    end

    it 'counts unsubmitted, unstarted applications without choices' do
      form = create(:application_form)

      expect(ProcessState.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_process_state(:unsubmitted_not_started_form)).to be(1)
    end

    it 'counts unsubmitted, started applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      application_choice.application_form.update_column(:updated_at, Time.zone.now + 1.day)

      expect(ProcessState.new(application_choice.application_form).state).to be :unsubmitted_in_progress

      expect(count_for_process_state(:unsubmitted_in_progress)).to be(1)
    end

    it 'counts awaiting references applications' do
      application_choice = create(:application_choice, status: 'awaiting_references')

      expect(ProcessState.new(application_choice.application_form).state).to be :awaiting_references

      expect(count_for_process_state(:awaiting_references)).to be(1)
    end

    it 'counts applications that are waiting to be sent to the provider' do
      application_choice = create(:application_choice, status: 'application_complete')

      expect(ProcessState.new(application_choice.application_form).state).to be :waiting_to_be_sent

      expect(count_for_process_state(:waiting_to_be_sent)).to be(1)
    end

    it 'counts applications awaiting a provider decision' do
      application_choice = create(:application_choice, status: 'awaiting_provider_decision')
      create(:application_choice, application_form: application_choice.application_form, status: 'offer')

      expect(ProcessState.new(application_choice.application_form).state).to be :awaiting_provider_decisions

      expect(count_for_process_state(:awaiting_provider_decisions)).to be(1)
    end

    it 'counts applications with offers' do
      form = create(:application_form)
      create_list(:application_choice, 2, application_form: form, status: 'offer')

      expect(ProcessState.new(form).state).to be :awaiting_candidate_response

      expect(count_for_process_state(:awaiting_candidate_response)).to be(1)
    end

    it 'counts enrolled applications' do
      application_choice = create(:application_choice, status: 'enrolled')

      expect(ProcessState.new(application_choice.application_form).state).to be :enrolled

      expect(count_for_process_state(:enrolled)).to be(1)
    end

    it 'counts recruited applications' do
      application_choice = create(:application_choice, status: 'recruited')

      expect(ProcessState.new(application_choice.application_form).state).to be :recruited

      expect(count_for_process_state(:recruited)).to be(1)
    end

    it 'counts applications pending conditions' do
      application_choice = create(:application_choice, status: 'pending_conditions')

      expect(ProcessState.new(application_choice.application_form).state).to be :pending_conditions

      expect(count_for_process_state(:pending_conditions)).to be(1)
    end

    it 'counts applications that ended without success' do
      withdrawn_form, rejected_form, declined_form, conditions_not_met_form = create_list(:application_form, 4)
      create_list(:application_choice, 2, application_form: withdrawn_form, status: 'withdrawn')
      create_list(:application_choice, 2, application_form: rejected_form, status: 'rejected')
      create_list(:application_choice, 2, application_form: declined_form, status: 'declined')
      create_list(:application_choice, 2, application_form: conditions_not_met_form, status: 'conditions_not_met')

      expect(ProcessState.new(withdrawn_form).state).to be :ended_without_success
      expect(ProcessState.new(rejected_form).state).to be :ended_without_success
      expect(ProcessState.new(declined_form).state).to be :ended_without_success
      expect(ProcessState.new(conditions_not_met_form).state).to be :ended_without_success

      expect(count_for_process_state(:ended_without_success)).to be(4)
    end
  end

  def count_for_process_state(process_state)
    PerformanceStatistics.new.candidate_status_counts.find { |x| x['status'] == process_state.to_s }['count']
  end

  it 'excludes candidates marked as hidden from reporting' do
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    visible_candidate = create(:candidate, hide_in_reporting: false)
    create(:application_form, candidate: hidden_candidate)
    create(:application_form, candidate: visible_candidate)

    stats = PerformanceStatistics.new

    expect(stats[:total_candidate_count]).to eq(1)
    expect(stats.candidate_counts_total).to eq(1)
  end

  it 'excludes candidates without application forms' do
    create(:candidate)

    stats = PerformanceStatistics.new

    expect(stats.candidate_counts_total).to eq(0)
  end

  it 'breaks down candidates with unsubmitted forms into stages' do
    create(:candidate)
    create_list(:application_form, 2)
    create_list(:application_form, 3, updated_at: 3.minutes.from_now) # changed forms
    create_list(:completed_application_form, 4, updated_at: 3.minutes.from_now)

    stats = PerformanceStatistics.new

    expect(stats[:total_candidate_count]).to eq(10)
    expect(stats[:candidates_signed_up_but_not_signed_in]).to eq(1)
    expect(stats[:candidates_signed_in_but_not_entered_data]).to eq(2)
    expect(stats[:candidates_with_unsubmitted_forms]).to eq(3)
    expect(stats[:candidates_with_submitted_forms]).to eq(4)
  end

  it 'avoids double counting generated test data' do
    form = create(:completed_application_form)
    form.update_column(:updated_at, form.created_at) # this form is both unchanged but also submitted

    stats = PerformanceStatistics.new

    expect(stats[:total_candidate_count]).to eq(1)
    expect(stats[:candidates_with_submitted_forms]).to eq(1)
    expect(stats[:candidates_signed_in_but_not_entered_data]).to eq(0)
  end
end
