require 'rails_helper'

RSpec.describe ApplyAgainFeatureMetrics do
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
        create(
          :application_choice,
          :with_offer,
          application_form: application_form,
        )
      end

      def reject(application_form)
        create(
          :application_choice,
          :with_rejection,
          application_form: application_form,
        )
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
    end
  end
end
