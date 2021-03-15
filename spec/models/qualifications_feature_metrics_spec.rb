require 'rails_helper'

RSpec.describe QualificationsFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  def create_application(a_level_count = 0)
    application_form = create(:completed_application_form, submitted_at: Time.zone.now)
    a_level_count.times do
      create(
        :other_qualification,
        qualification_type: 'A level',
        application_form: application_form,
      )
    end
    application_form
  end

  describe '#formatted_a_level_percentage' do
    context 'without any data' do
      it 'returns n/a' do
        expect(feature_metrics.formatted_a_level_percentage(1, 1.month.ago)).to eq('n/a')
      end
    end

    context 'with applications with A levels' do
      it 'returns 0 when there are no applications with A levels' do
        create_application
        expect(feature_metrics.formatted_a_level_percentage(1, 1.month.ago)).to eq('0%')
      end

      it 'returns 50% when there one of two applications has A levels' do
        create_application
        create_application(1)
        create_application(3)
        expect(feature_metrics.formatted_a_level_percentage(1, 1.month.ago)).to eq('66.7%')
        expect(feature_metrics.formatted_a_level_percentage(3, 1.month.ago)).to eq('33.3%')
      end

      it 'returns the right percentages when there are multiple applications with A levels' do
        @today = Time.zone.local(2021, 3, 10, 12)
        Timecop.freeze(@today - 40.days) do
          create_application
          create_application(1)
        end
        Timecop.freeze(@today - 20.days) do
          create_application(2)
        end
        Timecop.freeze(@today - 5.days) do
          create_application(3)
        end
        Timecop.freeze(@today) do
          expect(feature_metrics.formatted_a_level_percentage(1, 25.days.ago)).to eq('100%')
          expect(feature_metrics.formatted_a_level_percentage(3, 25.days.ago)).to eq('50%')
          expect(feature_metrics.formatted_a_level_percentage(2, 25.days.ago, 10.days.ago)).to eq('100%')
          expect(feature_metrics.formatted_a_level_percentage(3, 25.days.ago, 10.days.ago)).to eq('0%')
          expect(feature_metrics.formatted_a_level_percentage(1, 45.days.ago)).to eq('75%')
        end
      end
    end
  end
end
