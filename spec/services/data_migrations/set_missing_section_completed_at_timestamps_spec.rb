require 'rails_helper'

RSpec.describe DataMigrations::SetMissingSectionCompletedAtTimestamps do
  let!(:application_form) do
    create(:application_form, *traits, created_at: 1.day.ago, **attrs)
  end

  let(:traits) { [] }
  let(:attrs) { {} }
  let(:personal_details_completed_at) { nil }

  before do
    application_form.update_columns(personal_details_completed_at:)
  end

  context 'when the form is not carried over' do
    let(:attrs) { { personal_details_completed: true } }

    it 'does not set the timestamps' do
      described_class.new.change

      expect(application_form.reload.personal_details_completed_at).to be_nil
    end
  end

  context 'when the form is carried over' do
    let(:traits) { [:carry_over] }
    let(:attrs) { { personal_details_completed: true } }

    it 'sets the timestamps' do
      described_class.new.change

      expect(application_form.reload.personal_details_completed_at.iso8601).to eq(1.day.ago.iso8601)
    end

    context 'but the section is not completed' do
      let(:attrs) { { personal_details_completed: false } }

      it 'does not set the timestamp' do
        described_class.new.change

        expect(application_form.reload.personal_details_completed_at).to be_nil
      end
    end

    context 'and the timestamp is already set' do
      let(:personal_details_completed_at) { 3.days.ago }

      it 'does not set the timestamp' do
        described_class.new.change

        expect(application_form.reload.personal_details_completed_at.iso8601).to eq(3.days.ago.iso8601)
      end
    end
  end

  context 'when the form has a previous application' do
    let(:traits) { [:carry_over] }
    let(:attrs) { { personal_details_completed: true } }

    it 'sets the timestamps' do
      described_class.new.change

      expect(application_form.reload.personal_details_completed_at.iso8601).to eq(1.day.ago.iso8601)
    end

    context 'but the section is not completed' do
      let(:attrs) { { personal_details_completed: false } }

      it 'does not set the timestamp' do
        described_class.new.change

        expect(application_form.reload.personal_details_completed_at).to be_nil
      end
    end

    context 'and the timestamp is already set' do
      let(:personal_details_completed_at) { 3.days.ago }

      it 'does not set the timestamp' do
        described_class.new.change

        expect(application_form.reload.personal_details_completed_at.iso8601).to eq(3.days.ago.iso8601)
      end
    end
  end
end
