require 'rails_helper'

RSpec.describe WorkHistoryFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  describe '#average_time_to_complete' do
    context 'without any data' do
      it 'just returns n/a' do
        expect(feature_metrics.average_time_to_complete(1.month.ago)).to eq('n/a')
      end
    end

    context 'with reference data' do
      before do
        @today = Time.zone.local(2020, 12, 31, 12)
        Timecop.freeze(@today - 11.days) do
          @application_form1 = create(:application_form)
          @application_form2 = create(:application_form)
        end
        Timecop.freeze(@today - 10.days) do
          create(:application_work_experience, application_form: @application_form1)
          create(:application_work_experience, application_form: @application_form2)
        end
        Timecop.freeze(@today - 8.days) do
          @application_form1.update!(work_history_completed: true)
        end
        Timecop.freeze(@today - 1.day) do
          @application_form2.update!(work_history_completed: true)
        end
      end

      it 'returns the correct value for references received in the past week' do
        expect(feature_metrics.average_time_to_complete((@today - 1.week), @today)).to eq('9')
      end

      it 'returns the correct value for references received in the past month' do
        expect(feature_metrics.average_time_to_complete((@today - 1.month).beginning_of_day, @today)).to eq('5.5')
      end
    end
  end
end
