require 'rails_helper'

RSpec.describe ApplyAgainFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  describe '#success_rate' do
    context 'without any data' do
      it 'just returns 0' do
        expect(feature_metrics.success_rate(1.month.ago)).to eq(0)
      end
    end

    context 'with apply again applications' do
      def create_apply_again_application
        original_application = create(
          :completed_application_form,
        )
        apply_again_application_form = DuplicateApplication.new(
          original_application,
          target_phase: 'apply_2',
        ).duplicate

        apply_again_application_form
      end

      def make_offer_for(application_form)
        application_choice = create(
          :application_choice,
          :awaiting_provider_decision,
          application_form: application_form,
        )
        ApplicationStateChange.new(application_choice).make_offer!
      end

      def reject(application_form)
        application_choice = create(
          :application_choice,
          :awaiting_provider_decision,
          application_form: application_form,
        )
        ApplicationStateChange.new(application_choice).reject!
      end

      it 'returns 0 when there are no successful apply again applications' do
        create_apply_again_application
        expect(feature_metrics.success_rate(1.month.ago)).to eq(0)
      end

      it 'returns 0.5 when 50% of apply again applications are successful' do
        create_apply_again_application
        reject(create_apply_again_application)
        make_offer_for(create_apply_again_application)
        expect(feature_metrics.success_rate(1.month.ago)).to eq(0.5)
      end

      it 'returns 1.0 when 100% of apply again applications are successful within given time range' do
        @today = Time.zone.local(2020, 12, 31, 12)
        Timecop.freeze(@today - 20.days) do
          create_apply_again_application
          reject(create_apply_again_application)
        end
        Timecop.freeze(@today - 10.days) do
          make_offer_for(create_apply_again_application)
        end
        Timecop.freeze(@today - 5.days) do
          reject(create_apply_again_application)
        end
        expect(feature_metrics.success_rate(@today - 12.days, @today - 8.days)).to eq(1.0)
        expect(feature_metrics.success_rate(@today - 12.days, @today - 3.days)).to eq(0.5)
        expect(feature_metrics.success_rate(@today - 22.days, @today - 3.days)).to be_within(0.01).of(0.33)
      end
    end
  end
end
