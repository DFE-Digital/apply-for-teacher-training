require 'rails_helper'

RSpec.describe ApplicationDates do
  let(:submitted_at) { Time.zone.local(current_year, 5, 1, 12, 0, 0).end_of_day }

  let(:application_form) do
    create(:application_form, submitted_at:, application_choices: [application_choice])
  end

  let(:application_choice) { build(:application_choice) }

  subject(:application_dates) do
    described_class.new(application_form)
  end

  describe '#submitted_at' do
    context 'when before continuous applications' do
      let(:submitted_at) { Time.zone.local(2023, 5, 1, 12, 0, 0).end_of_day }

      let(:application_form) do
        create(:application_form, :pre_continuous_applications, submitted_at:, application_choices: [application_choice])
      end

      it 'returns submitted at' do
        expect(application_dates.submitted_at).to be_within(1.second).of(submitted_at)
      end
    end

    context 'when continuous applications' do
      let(:submitted_at) { 1.month.ago }

      context 'when application is submitted' do
        before do
          create(:application_choice, :awaiting_provider_decision, application_form:, sent_to_provider_at: 1.day.ago)
        end

        it 'returns submitted at' do
          expect(application_dates.submitted_at).to be_within(1.second).of(submitted_at)
        end
      end

      context 'when application is accepted' do
        let(:sent_to_provider_at) { 1.day.ago }

        before do
          create(:application_choice, :accepted, application_form:, sent_to_provider_at:)
        end

        it 'returns sent to provider at' do
          expect(application_dates.submitted_at).to be_within(1.second).of(sent_to_provider_at)
        end
      end
    end
  end

  describe '#reject_by_default_at' do
    it 'return nil when the reject_by_default_at is not set' do
      expect(application_dates.reject_by_default_at).to be_nil
    end

    it 'returns date that providers will respond by when reject_by_default_at is set' do
      reject_by_default_at = Time.zone.local(current_year, 6, 28, 23, 59, 59)
      application_form.application_choices.each do |application_choice|
        application_choice.update(reject_by_default_at:)
      end
      expect(application_dates.reject_by_default_at).to eql reject_by_default_at
    end
  end
end
