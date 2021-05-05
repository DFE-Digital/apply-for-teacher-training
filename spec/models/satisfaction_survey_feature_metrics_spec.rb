require 'rails_helper'

RSpec.describe SatisfactionSurveyFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  def create_application
    application_form = create(:completed_application_form, submitted_at: Time.zone.now)
    application_form
  end

  def create_application_with_feeback
    application_form2 = create(:completed_application_form, :with_feedback_completed, submitted_at: Time.zone.now)
    application_form2
  end

  describe '#formatted_response_rate' do
    context 'without any data' do
      it 'returns n/a' do
        expect(feature_metrics.formatted_response_rate(1.month.ago)).to eq('n/a')
      end
    end

    context 'with applications with feedback' do
      it 'returns 0 when there are no applications with feedback' do
        create_application
        expect(feature_metrics.formatted_response_rate(1.month.ago)).to eq('0%')
      end

      it 'returns the right percentages when applications with feedback exist' do
        create_application
        2.times { create_application_with_feeback }
        expect(feature_metrics.formatted_response_rate(1.month.ago)).to eq('66.7%')
      end

      it 'returns the right percentages over a range of dates' do
        @today = Time.zone.local(2021, 3, 10, 12)
        Timecop.freeze(@today - 40.days) do
          2.times { create_application_with_feeback }
        end
        Timecop.freeze(@today - 20.days) do
          create_application
        end
        Timecop.freeze(@today - 5.days) do
          create_application_with_feeback
        end
        Timecop.freeze(@today) do
          expect(feature_metrics.formatted_response_rate(25.days.ago)).to eq('50%')
          expect(feature_metrics.formatted_response_rate(25.days.ago, 10.days.ago)).to eq('0%')
          expect(feature_metrics.formatted_response_rate(45.days.ago)).to eq('75%')
        end
      end
    end
  end
end
