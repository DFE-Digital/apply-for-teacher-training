require 'rails_helper'

RSpec.describe FeatureMetricsDashboard do
  describe '#write_metric' do
    context 'the #metrics attribute is nil' do
      let(:dashboard) { described_class.new }

      it 'writes the given key/value pair' do
        dashboard.write_metric(:test, :value)
        expect(dashboard.metrics).to eq('test' => 'value')
      end
    end

    context 'the #metrics attribute already contains a hash' do
      let(:dashboard) { described_class.new(metrics: { existing: :value }) }

      it 'adds new values' do
        dashboard.write_metric(:new, :value)
        expect(dashboard.metrics).to eq(
          'existing' => 'value',
          'new' => 'value',
        )
      end

      it 'overrides existing values' do
        dashboard.write_metric(:existing, :changed_value)
        expect(dashboard.metrics).to eq('existing' => 'changed_value')
      end
    end
  end

  describe '#read_metric' do
    let(:dashboard) { described_class.new(metrics: { 'test' => 'value' }) }

    it 'returns the matching value' do
      expect(dashboard.read_metric('test')).to eq 'value'
    end

    it 'accepts key names as both strings and symbols' do
      expect(dashboard.read_metric(:test)).to eq 'value'
    end

    it 'returns a placeholder "missing value" if the key is not found' do
      expect(dashboard.read_metric(:testttt)).to eq 'n/a'
    end
  end

  describe '#load_updated_metrics' do
    it 'retrieves all required metrics' do
      reference_metrics_double = instance_double(ReferenceFeatureMetrics)
      work_history_metrics_double = instance_double(WorkHistoryFeatureMetrics)
      magic_link_metrics_double = instance_double(MagicLinkFeatureMetrics)
      rfr_metrics_double = instance_double(ReasonsForRejectionFeatureMetrics)
      apply_again_metrics_double = instance_double(ApplyAgainFeatureMetrics)
      carry_over_metrics_double = instance_double(CarryOverFeatureMetrics)
      qualifications_metrics_double = instance_double(QualificationsFeatureMetrics)

      allow(ReferenceFeatureMetrics).to receive(:new).and_return(reference_metrics_double)
      allow(WorkHistoryFeatureMetrics).to receive(:new).and_return(work_history_metrics_double)
      allow(MagicLinkFeatureMetrics).to receive(:new).and_return(magic_link_metrics_double)
      allow(ReasonsForRejectionFeatureMetrics).to receive(:new).and_return(rfr_metrics_double)
      allow(ApplyAgainFeatureMetrics).to receive(:new).and_return(apply_again_metrics_double)
      allow(CarryOverFeatureMetrics).to receive(:new).and_return(carry_over_metrics_double)
      allow(QualificationsFeatureMetrics).to receive(:new).and_return(qualifications_metrics_double)

      allow(reference_metrics_double).to receive(:average_time_to_get_references).and_return(1)
      allow(reference_metrics_double).to receive(:percentage_references_within).and_return(2)
      allow(work_history_metrics_double).to receive(:average_time_to_complete).and_return(3)
      allow(magic_link_metrics_double).to receive(:average_magic_link_requests_upto).and_return(4)
      allow(rfr_metrics_double).to receive(:rejections_due_to).and_return(5)
      allow(apply_again_metrics_double).to receive(:formatted_success_rate).and_return('42.8%')
      allow(apply_again_metrics_double).to receive(:formatted_change_rate).and_return('33.3%')
      allow(apply_again_metrics_double).to receive(:formatted_application_rate).and_return('18.7%')
      allow(carry_over_metrics_double).to receive(:carry_over_count).and_return(20)
      allow(qualifications_metrics_double).to receive(:formatted_a_level_percentage).and_return('30%')

      dashboard = described_class.new
      dashboard.load_updated_metrics

      expect(dashboard.metrics).to eq({
        'avg_time_to_get_references' => 1,
        'avg_time_to_get_references_this_month' => 1,
        'avg_time_to_get_references_last_month' => 1,
        'pct_references_completed_within_30_days' => 2,
        'pct_references_completed_within_30_days_this_month' => 2,
        'pct_references_completed_within_30_days_last_month' => 2,
        'avg_time_to_complete_work_history' => 3,
        'avg_time_to_complete_work_history_this_month' => 3,
        'avg_time_to_complete_work_history_last_month' => 3,
        'avg_sign_ins_before_submitting' => 4,
        'avg_sign_ins_before_submitting_this_month' => 4,
        'avg_sign_ins_before_submitting_last_month' => 4,
        'avg_sign_ins_before_offer' => 4,
        'avg_sign_ins_before_offer_this_month' => 4,
        'avg_sign_ins_before_offer_last_month' => 4,
        'avg_sign_ins_before_recruitment' => 4,
        'avg_sign_ins_before_recruitment_this_month' => 4,
        'avg_sign_ins_before_recruitment_last_month' => 4,
        'num_rejections_due_to_qualifications' => 5,
        'num_rejections_due_to_qualifications_this_month' => 5,
        'num_rejections_due_to_qualifications_last_month' => 5,
        'apply_again_success_rate' => '42.8%',
        'apply_again_success_rate_this_month' => '42.8%',
        'apply_again_success_rate_upto_this_month' => '42.8%',
        'apply_again_change_rate' => '33.3%',
        'apply_again_change_rate_this_month' => '33.3%',
        'apply_again_change_rate_last_month' => '33.3%',
        'apply_again_application_rate' => '18.7%',
        'apply_again_application_rate_this_month' => '18.7%',
        'apply_again_application_rate_upto_this_month' => '18.7%',
        'carry_over_count' => 20,
        'carry_over_count_this_month' => 20,
        'carry_over_count_last_month' => 20,
        'pct_applications_with_one_a_level' => '30%',
        'pct_applications_with_one_a_level_this_month' => '30%',
        'pct_applications_with_one_a_level_last_month' => '30%',
        'pct_applications_with_three_a_levels' => '30%',
        'pct_applications_with_three_a_levels_this_month' => '30%',
        'pct_applications_with_three_a_levels_last_month' => '30%',
      })
    end
  end
end
