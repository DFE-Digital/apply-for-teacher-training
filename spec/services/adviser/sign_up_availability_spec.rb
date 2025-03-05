require 'rails_helper'

RSpec.describe Adviser::SignUpAvailability do
  before do
    FeatureFlag.activate(:adviser_sign_up)

    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
    Rails.cache.clear
    Sidekiq::Worker.clear_all
  end

  let(:application_form) { build_stubbed(:application_form) }

  subject(:availability) { described_class.new(application_form) }

  describe '#eligible_for_an_adviser?' do
    context 'when the application form is eligible' do
      before do
        allow(application_form).to receive(:eligible_for_teaching_training_adviser?).and_return(true)
      end

      it { is_expected.to be_eligible_for_an_adviser }
    end

    context 'when the application form is not eligible' do
      before do
        allow(application_form).to receive(:eligible_for_teaching_training_adviser?).and_return(false)
      end

      let(:application_form) { create(:application_form) }

      it { is_expected.not_to be_eligible_for_an_adviser }
    end

    context 'refreshing the adviser status' do
      it 'queues the refresh worker' do
        expect {
          availability.eligible_for_an_adviser?
        }.to change(Adviser::RefreshAdviserStatusWorker.jobs, :size).from(0).to(1)
      end

      it 'does not queue the refresh worker if it has been refreshed recently' do
        availability.eligible_for_an_adviser?

        expect {
          availability.eligible_for_an_adviser?
        }.not_to change(Adviser::RefreshAdviserStatusWorker.jobs, :size)
      end
    end
  end

  describe '#already_assigned_to_an_adviser?' do
    context 'when the application form is assigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'assigned') }

      it { is_expected.to be_already_assigned_to_an_adviser }
    end

    context 'when the application form is previously assigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'previously_assigned') }

      it { is_expected.to be_already_assigned_to_an_adviser }
    end

    context 'when the application form is unassigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'unassigned') }

      it { is_expected.not_to be_already_assigned_to_an_adviser }
    end

    context 'when the application form is waiting to be assigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'waiting_to_be_assigned') }

      it { is_expected.not_to be_already_assigned_to_an_adviser }
    end

    context 'refreshing the adviser status' do
      it 'queues the refresh worker' do
        expect {
          availability.already_assigned_to_an_adviser?
        }.to change(Adviser::RefreshAdviserStatusWorker.jobs, :size).from(0).to(1)
      end

      it 'does not queue the refresh worker if it has been refreshed recently' do
        availability.already_assigned_to_an_adviser?

        expect {
          availability.already_assigned_to_an_adviser?
        }.not_to change(Adviser::RefreshAdviserStatusWorker.jobs, :size)
      end
    end
  end

  describe '#waiting_to_be_assigned_to_an_adviser?' do
    context 'when the application form is assigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'assigned') }

      it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'when the application form is previously assigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'previously_assigned') }

      it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'when the application form is unassigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'unassigned') }

      it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'when the application form is waiting to be assigned to an adviser' do
      let(:application_form) { create(:application_form, adviser_status: 'waiting_to_be_assigned') }

      it { is_expected.to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'refreshing the adviser status' do
      it 'queues the refresh worker' do
        expect {
          availability.waiting_to_be_assigned_to_an_adviser?
        }.to change(Adviser::RefreshAdviserStatusWorker.jobs, :size).from(0).to(1)
      end

      it 'does not queue the refresh worker if it has been refreshed recently' do
        availability.waiting_to_be_assigned_to_an_adviser?

        expect {
          availability.waiting_to_be_assigned_to_an_adviser?
        }.not_to change(Adviser::RefreshAdviserStatusWorker.jobs, :size)
      end
    end
  end
end
