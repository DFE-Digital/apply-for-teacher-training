require 'rails_helper'

RSpec.describe ProcessState do
  describe '#state' do
    it 'returns never_signed_in without an application' do
      state = described_class.new(nil).state

      expect(state).to be(:never_signed_in)
    end

    it 'returns unsubmitted without choices' do
      application_form = build_stubbed(:application_form)

      state = described_class.new(application_form).state

      expect(state).to be(:unsubmitted_not_started_form)
    end

    it 'returns unsubmitted_not_started_form when unsubmitted choices exist but form has not been updated' do
      application_form = build_stubbed(:application_form, application_choices: build_list(:application_choice, 2, status: 'unsubmitted'))
      state = described_class.new(application_form).state

      expect(state).to be(:unsubmitted_not_started_form)
    end

    it 'returns unsubmitted_not_started_form when unsubmitted choices exist but form has been updated' do
      application_form = build_stubbed(:application_form,
                                       application_choices: build_list(:application_choice, 2, status: 'unsubmitted'),
                                       updated_at: Time.zone.now + 1.day)
      state = described_class.new(application_form).state

      expect(state).to be(:unsubmitted_in_progress)
    end

    it 'returns awaiting when not all providers have made a decision' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_provider_decision')
      create(:application_choice, application_form: application_form, status: 'offer')

      state = described_class.new(application_form).state

      expect(state).to be(:awaiting_provider_decisions)
    end

    it 'is waiting on candidate when there is an offer' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'offer')

      state = described_class.new(application_form).state

      expect(state).to be(:awaiting_candidate_response)
    end

    it 'is pending conditions when the candidate has accepted' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'pending_conditions')

      state = described_class.new(application_form).state

      expect(state).to be(:pending_conditions)
    end

    it 'is recruited when the candidate has been recruited' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'recruited')

      state = described_class.new(application_form).state

      expect(state).to be(:recruited)
    end

    it 'is "ended without success" when the candidate has no succesfull applications' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'withdrawn')
      create(:application_choice, application_form: application_form, status: 'rejected')
      create(:application_choice, application_form: application_form, status: 'declined')

      state = described_class.new(application_form).state

      expect(state).to be(:ended_without_success)
    end

    it 'is "ended without success" when the candidate has no succesful applications' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'declined')

      state = described_class.new(application_form).state

      expect(state).to be(:ended_without_success)
    end
  end
end
