require 'rails_helper'

RSpec.describe ReferenceFeatureMetrics, with_audited: true do
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
      Timecop.freeze(@today - 12.days + 2.hours) do
        @application_form1 = create(:application_form)
        @references1 = create_list(:reference, 2, application_form: @application_form1)
        @references1.each { |reference| RequestReference.new.call(reference) }

        @application_form2 = create(:application_form)
        @references2 = create_list(:reference, 2, application_form: @application_form2)
        @references2.each { |reference| RequestReference.new.call(reference) }

        @application_form3 = create(:application_form)
        @references3 = create_list(:reference, 2, application_form: @application_form3)
        @references3.each { |reference| RequestReference.new.call(reference) }
      end
      Timecop.freeze(@today - 10.days) do
        SubmitReference.new(reference: @references1.first, send_emails: false).save!
      end
      Timecop.freeze(@today - 9.days - 2.hours) do
        SubmitReference.new(reference: @references1.second, send_emails: false).save!
      end
      Timecop.freeze(@today - 1.day) do
        SubmitReference.new(reference: @references2.second, send_emails: false).save!
        @apply_again_application_form = DuplicateApplication.new(@application_form1, target_phase: :apply_2).clone
      end
      Timecop.freeze(@today) do
        SubmitReference.new(reference: @references2.first, send_emails: false).save!
        SubmitReference.new(reference: @references3.second, send_emails: false).save!
      end
      Timecop.freeze(@today + 1.day) do
        SubmitReference.new(reference: @references3.first, send_emails: false).save!
      end

      create(:application_choice, :with_rejection, application_form: @application_form1)

      ApplyAgain.new(@application_form1).call
    end

    describe '#average_time_to_get_references' do
      it 'returns the correct value for references received today' do
        expect(feature_metrics.average_time_to_get_references(@today.beginning_of_day, @today)).to eq('11.9 days')
      end

      it 'returns the correct value for references received in the past month' do
        expect(feature_metrics.average_time_to_get_references((@today - 1.month).beginning_of_day, @today)).to eq('7.4 days')
      end

      it 'returns the correct value for references received over a custom interval' do
        expect(feature_metrics.average_time_to_get_references((@today - 1.month).beginning_of_day, @today - 1.week)).to eq('2.8 days')
      end

      it 'handles missing `requested_at` timestamp' do
        @references1.first.update!(requested_at: nil)
        expect(feature_metrics.average_time_to_get_references((@today - 1.month).beginning_of_day, @today)).to eq('7.4 days')
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
