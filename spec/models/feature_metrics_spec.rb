require 'rails_helper'

RSpec.describe FeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  context 'without any data' do
    describe '#average_time_to_get_references' do
      it 'just returns n/a' do
        expect(feature_metrics.average_time_to_get_references(1.month.ago)).to eq('n/a')
      end
    end

    describe '#percentage_references_within' do
      it 'just returns n/a' do
        expect(feature_metrics.percentage_references_within(30, 1.month.ago)).to eq('n/a')
      end
    end
  end

  context 'with reference data' do
    before do
      @today = Time.zone.local(2020, 12, 31, 12)
      Timecop.freeze(@today - 12.days) do
        @application_form1 = create(:application_form)
        @references1 = create_list(:reference, 2, application_form: @application_form1)
        @references1.each { |reference| CandidateInterface::RequestReference.new.call(reference) }

        @application_form2 = create(:application_form)
        @references2 = create_list(:reference, 2, application_form: @application_form2)
        @references2.each { |reference| CandidateInterface::RequestReference.new.call(reference) }
      end
      Timecop.freeze(@today - 9.days) do
        @references1.each { |reference| SubmitReference.new(reference: reference, send_emails: false).save! }
      end
      Timecop.freeze(@today) do
        @references2.each { |reference| SubmitReference.new(reference: reference, send_emails: false).save! }
      end
    end

    describe '#average_time_to_get_references' do
      it 'returns the correct value for references received today' do
        expect(feature_metrics.average_time_to_get_references(@today.beginning_of_day, @today)).to eq('12')
      end

      it 'returns the correct value for references received in the past month' do
        expect(feature_metrics.average_time_to_get_references((@today - 1.month).beginning_of_day, @today)).to eq('7.5')
      end

      it 'returns the correct value for references received over a custom interval' do
        expect(feature_metrics.average_time_to_get_references((@today - 1.month).beginning_of_day, @today - 1.week)).to eq('3')
      end
    end

    describe '#percentage_references_within' do
      it 'returns the correct percentage of references received in 30 days today' do
        expect(feature_metrics.percentage_references_within(30, @today.beginning_of_day, @today)).to eq('100%')
      end

      it 'returns the correct percentage of references received in 10 days today' do
        expect(feature_metrics.percentage_references_within(10, @today.beginning_of_day, @today)).to eq('0%')
      end

      it 'returns the correct percentage of references received in 30 days the past month' do
        expect(feature_metrics.percentage_references_within(30, (@today - 1.month).beginning_of_day, @today)).to eq('100%')
      end

      it 'returns the correct percentage of references received in 10 days the past month' do
        expect(feature_metrics.percentage_references_within(10, (@today - 1.month).beginning_of_day, @today)).to eq('50%')
      end
    end
  end
end
