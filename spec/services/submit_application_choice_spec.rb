require 'rails_helper'

RSpec.describe SubmitApplicationChoice do
  let(:current_date) { Time.zone.local(2020, 3, 1) }
  let(:application_form) { create(:application_form, submitted_at: Time.zone.now) }
  let(:application_choice) { create(:application_choice, application_form: application_form, status: 'unsubmitted') }

  around do |example|
    Timecop.freeze(current_date) do
      example.run
    end
  end

  describe 'Submit an application choice', sandbox: false do
    it 'updates the application choice to Awaiting References' do
      SubmitApplicationChoice.new(application_choice).call

      expect(application_choice).to be_awaiting_references
    end

    context 'when running in a provider sandbox', sandbox: true do
      it 'sets the edit_by timestamp to now' do
        SubmitApplicationChoice.new(application_choice).call

        expect(application_choice.edit_by).to eq(current_date)
      end
    end

    context 'when edit by days are in calendar days' do
      it 'updates the application choice to edit_by date' do
        allow(TimeLimitConfig).to receive(:edit_by).and_return(TimeLimitConfig::Days.new(count: 7, type: :calendar))

        SubmitApplicationChoice.new(application_choice).call

        expect(application_choice.edit_by.to_s).to eq(Time.zone.local(2020, 3, 8, 23, 59, 59).to_s)
      end
    end

    context 'when edit by days are in working days' do
      it 'updates the application choice to edit_by date' do
        allow(TimeLimitConfig).to receive(:edit_by).and_return(TimeLimitConfig::Days.new(count: 7, type: :working))

        SubmitApplicationChoice.new(application_choice).call

        expect(application_choice.edit_by.to_s).to eq(Time.zone.local(2020, 3, 11, 23, 59, 59).to_s)
      end
    end
  end

  describe 'Submit an Apply Again application choice' do
    let(:submit_application_choice) do
      SubmitApplicationChoice.new(
        application_choice,
        apply_again: apply_again,
        enough_references: enough_references,
      ).call
    end

    let(:apply_again) { true }

    context 'and enough references have been provided' do
      let(:enough_references) { true }

      it 'sets the edit_by timestamp to now' do
        submit_application_choice

        expect(application_choice.edit_by).to eq(Time.zone.now)
      end

      it 'updates the application choice state to Application Complete' do
        submit_application_choice

        expect(application_choice).to be_application_complete
      end
    end

    context 'and not enough references have been provided' do
      let(:enough_references) { false }

      it 'updates the application choice to Awaiting References' do
        submit_application_choice

        expect(application_choice).to be_awaiting_references
      end

      it 'sets the edit_by timestamp according to TimeLimitConfig' do
        allow(TimeLimitConfig).to receive(:edit_by).and_return(TimeLimitConfig::Days.new(count: 7, type: :working))

        submit_application_choice

        expect(application_choice.edit_by.to_s).to eq(Time.zone.local(2020, 3, 11, 23, 59, 59).to_s)
      end
    end
  end

  describe 'Submit an application choice with the move_edit_by_to_application_form flag on', sandbox: false do
    it 'updates the application choice to Awaiting References' do
      FeatureFlag.activate('move_edit_by_to_application_form')
      SubmitApplicationChoice.new(application_choice).call

      expect(application_choice).to be_awaiting_references
    end
  end

  describe 'Submit an Apply Again application choice with the move_edit_by_to_application_form on' do
    let(:submit_application_choice) do
      SubmitApplicationChoice.new(
        application_choice,
        apply_again: apply_again,
        enough_references: enough_references,
      ).call
    end

    let(:apply_again) { true }

    before do
      FeatureFlag.activate('move_edit_by_to_application_form')
    end

    context 'and enough references have been provided' do
      let(:enough_references) { true }

      it 'updates the application choice state to Application Complete' do
        submit_application_choice

        expect(application_choice).to be_application_complete
      end
    end

    context 'and not enough references have been provided' do
      let(:enough_references) { false }

      it 'updates the application choice to Awaiting References' do
        submit_application_choice

        expect(application_choice).to be_awaiting_references
      end
    end
  end
end
