require 'rails_helper'

RSpec.describe ReasonsForRejectionFeatureMetrics do
  subject(:feature_metrics) { described_class.new }

  describe '#rejections_due_to' do
    context 'without any data' do
      it 'just returns 0' do
        expect(feature_metrics.rejections_due_to(:qualifications_y_n, 1.month.ago)).to eq(0)
      end
    end

    def reject_application(application_choice, reasons)
      ApplicationStateChange.new(application_choice).reject!
      application_choice.update!(
        structured_rejection_reasons: reasons,
        rejected_at: Time.zone.now,
      )
    end

    context 'with rejection data' do
      before do
        @today = Time.zone.local(2020, 12, 31, 12)
        Timecop.freeze(@today - 12.days) do
          @application_choice1 = create(:application_choice, :awaiting_provider_decision)
          @application_choice2 = create(:application_choice, :awaiting_provider_decision)
          @application_choice3 = create(:application_choice, :awaiting_provider_decision)
        end
        Timecop.freeze(@today - 9.days) do
          reject_application(
            @application_choice1,
            { qualifications_y_n: 'Yes' }
          )
          reject_application(
            @application_choice2,
            { qualifications_y_n: 'No' }
          )
        end
        Timecop.freeze(@today - 1.day) do
          reject_application(
            @application_choice3,
            { qualifications_y_n: 'Yes' }
          )
        end
      end

      it 'returns the correct value for number of rejections due to qualifications in the last week' do
        expect(feature_metrics.rejections_due_to(
          :qualifications_y_n,
          (@today - 1.week).beginning_of_day,
          @today,
        )).to eq(1)
      end

      it 'returns the correct value for number of rejections due to qualifications in the last month' do
        expect(feature_metrics.rejections_due_to(
          :qualifications_y_n,
          (@today - 1.month).beginning_of_day,
        )).to eq(2)
      end

      it 'returns the correct value for number of rejections due to quality of application in the last month' do
        expect(feature_metrics.rejections_due_to(
          :quality_of_application_y_n,
          (@today - 1.month).beginning_of_day,
        )).to eq(0)
      end
    end
  end
end
