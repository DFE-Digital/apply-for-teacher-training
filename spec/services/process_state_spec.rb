require 'rails_helper'

RSpec.describe ProcessState do
  describe '#state' do
    it 'returns unsubmitted without choices' do
      application_form = build_stubbed(:application_form)

      state = ProcessState.new(application_form).state

      expect(state).to be(:unsubmitted)
    end

    it 'returns unsubmitted with unsubmitted choices' do
      application_form = build_stubbed(:application_form, application_choices: build_list(:application_choice, 2, status: 'unsubmitted'))

      state = ProcessState.new(application_form).state

      expect(state).to be(:unsubmitted)
    end

    it 'returns awaiting_references when awaiting references' do
      application_form = build_stubbed(:application_form, application_choices: build_list(:application_choice, 2, status: 'awaiting_references'))

      state = ProcessState.new(application_form).state

      expect(state).to be(:awaiting_references)
    end

    it 'returns waiting_to_be_sent when awaiting application complete' do
      application_form = build_stubbed(:application_form, application_choices: build_list(:application_choice, 2, status: 'application_complete'))

      state = ProcessState.new(application_form).state

      expect(state).to be(:waiting_to_be_sent)
    end

    it 'returns awaiting when not all providers have made a decision' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_provider_decision')
      create(:application_choice, application_form: application_form, status: 'offer')

      state = ProcessState.new(application_form).state

      expect(state).to be(:awaiting_provider_decisions)
    end

    it 'is waiting on candidate when there is an offer' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'offer')

      state = ProcessState.new(application_form).state

      expect(state).to be(:awaiting_candidate_response)
    end

    it 'is pending conditions when the candidate has accepted' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'pending_conditions')

      state = ProcessState.new(application_form).state

      expect(state).to be(:pending_conditions)
    end

    it 'is recruited when the candidate has been recruited' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'recruited')

      state = ProcessState.new(application_form).state

      expect(state).to be(:recruited)
    end

    it 'is enrolled when the candidate has been enrolled' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'enrolled')

      state = ProcessState.new(application_form).state

      expect(state).to be(:enrolled)
    end

    it 'is "ended without success" when the candidate has no succesfull applications' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'withdrawn')
      create(:application_choice, application_form: application_form, status: 'rejected')
      create(:application_choice, application_form: application_form, status: 'declined')

      state = ProcessState.new(application_form).state

      expect(state).to be(:ended_without_success)
    end

    it 'is "ended without success" when the candidate has no succesful applications' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'declined')

      state = ProcessState.new(application_form).state

      expect(state).to be(:ended_without_success)
    end
  end
end
