require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReminderWorker do
  include ActiveSupport::Testing::TimeHelpers

  let(:cycle_week) { RecruitmentCycleTimetable.current_cycle_week.pred }
  let(:recruitment_cycle_year) { RecruitmentCycleTimetable.current_year }
  let(:provider) { create(:provider, :no_users) }
  let!(:provider_user) { create(:provider_user, providers: [provider]) }

  let(:national_recruitment_performance_report) do
    create(:national_recruitment_performance_report, cycle_week:, recruitment_cycle_year:)
  end

  let(:provider_recruitment_performance_report) do
    create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year:)
  end

  describe '#perform' do
    context 'when no national recruitment performance report exists' do
      it 'returns nil' do
        expect(described_class.new.perform).to be_nil
      end
    end

    context 'when no provider recruitment performance report exists for the given provider' do
      before do
        national_recruitment_performance_report
        create(:provider_recruitment_performance_report, cycle_week:, recruitment_cycle_year:)
        allow(ProviderMailer).to receive(:recruitment_performance_report_reminder).and_call_original
      end

      it 'does not send an email to the provider user' do
        described_class.new.perform
        expect(ProviderMailer).not_to have_received(:recruitment_performance_report_reminder).with(provider_user)
      end
    end

    context 'when a national recruitment performance report exists' do
      before do
        national_recruitment_performance_report
        provider_recruitment_performance_report
        allow(ProviderMailer).to receive(:recruitment_performance_report_reminder).and_call_original
      end

      it 'sends an email to the provider user' do
        described_class.new.perform
        expect(ProviderMailer).to have_received(:recruitment_performance_report_reminder).with(provider_user)
      end
    end

    context 'when batching emails fewer than 3000 emails' do
      let(:relation_double) { instance_double(ActiveRecord::Relation) }
      let(:users_double) { Array.new(300) { instance_double(ProviderUser) } }
      let(:scheduled_times) { [] }

      before do
        national_recruitment_performance_report
        provider_recruitment_performance_report
      end

      it 'schedules emails with even spacing over 5 minutes' do
        travel_to Time.zone.local(2026, 2, 3, 17, 0, 0) do
          allow(ProviderUser).to receive(:joins).with(:provider_permissions).and_return(relation_double)
          allow(relation_double).to receive(:where).and_return(users_double)

          mail_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
          allow(ProviderMailer).to receive(:recruitment_performance_report_reminder).and_return(mail_double)

          allow(mail_double).to receive(:deliver_later) do |wait_until:|
            scheduled_times << wait_until
          end

          described_class.new.perform

          expect(scheduled_times.size).to eq(300)
          expect(scheduled_times.uniq).to eq([
            Time.zone.local(2026, 2, 3, 17, 0, 0),
            Time.zone.local(2026, 2, 3, 17, 2, 30),
            Time.zone.local(2026, 2, 3, 17, 5, 0),
          ])
        end
      end
    end

    context 'when batching more than 3000 emails' do
      let(:relation_double) { instance_double(ActiveRecord::Relation) }
      let(:users_double) { Array.new(7000) { instance_double(ProviderUser) } }
      let(:scheduled_times) { [] }

      before do
        national_recruitment_performance_report
        provider_recruitment_performance_report
      end

      it 'distributes emails across an appropriate stagger window' do
        travel_to Time.zone.local(2026, 2, 3, 17, 0, 0) do
          allow(ProviderUser).to receive(:joins).with(:provider_permissions).and_return(relation_double)
          allow(relation_double).to receive(:where).and_return(users_double)

          mail_double = instance_double(ActionMailer::MessageDelivery)
          allow(ProviderMailer).to receive(:recruitment_performance_report_reminder).and_return(mail_double)

          allow(mail_double).to receive(:deliver_later) do |wait_until:|
            scheduled_times << wait_until
          end

          described_class.new.perform

          expect(scheduled_times.size).to eq(7000)
          expect(scheduled_times.uniq.count).to eq(70)
          expect(scheduled_times.uniq.first).to eq(Time.zone.local(2026, 2, 3, 17, 0, 0))
          expect(scheduled_times.uniq.last).to be_within(1.second).of(Time.zone.local(2026, 2, 3, 17, 14)) # 14 minutes
        end
      end
    end
  end
end
