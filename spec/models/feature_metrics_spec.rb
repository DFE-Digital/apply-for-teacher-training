require 'rails_helper'

RSpec.describe FeatureMetrics, with_audited: true do
  describe '#time_to_get_references' do
    context 'without any data' do
      it 'just returns n/a' do
        expect(subject.time_to_get_references(1.month.ago)).to eq('n/a')
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

      it 'returns the correct value for references received today' do
        expect(subject.time_to_get_references(@today.beginning_of_day, @today)).to eq('12')
      end

      it 'returns the correct value for references received in the past month' do
        expect(subject.time_to_get_references((@today - 1.month).beginning_of_day, @today)).to eq('7.5')
      end

      it 'returns the correct value for references received over a custom interval' do
        expect(subject.time_to_get_references((@today - 1.month).beginning_of_day, @today - 1.week)).to eq('3')
      end
    end
  end
end
