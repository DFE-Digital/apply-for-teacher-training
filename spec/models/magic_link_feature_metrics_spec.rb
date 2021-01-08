require 'rails_helper'

RSpec.describe MagicLinkFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  describe '#average_magic_link_requests' do
    context 'without any data' do
      it 'just returns n/a' do
        expect(feature_metrics.average_magic_link_requests_upto(:offered_at, 1.month.ago)).to eq('n/a')
      end
    end

    context 'with data' do
      before do
        @today = Time.zone.local(2020, 12, 31, 12)
        Timecop.freeze(@today - 40.days) do
          @application_form1 = create(:application_form)
          @application_form2 = create(:application_form)
          @application_form1.candidate.update!(magic_link_token: '123456')
          @application_form1.candidate.update!(magic_link_token: '234567')
          @application_form2.candidate.update!(magic_link_token: '123456')
        end
        Timecop.freeze(@today - 9.days) do
          @application_choice1 = create(
            :application_choice,
            application_form: @application_form1,
            offered_at: Time.zone.now,
          )
        end
        Timecop.freeze(@today - 2.days) do
          @application_choice2 = create(
            :application_choice,
            application_form: @application_form2,
              offered_at: Time.zone.now,
          )
        end
        Timecop.freeze(@today - 1.days) do
          @application_form1.candidate.update!(magic_link_token: '345678')
          @application_form2.candidate.update!(magic_link_token: '234567')
        end
      end

      it 'returns the correct value for the past month' do
        expect(feature_metrics.average_magic_link_requests_upto(:offered_at, @today - 1.month, @today)).to eq('1.5')
      end

      it 'returns the correct value for the past week' do
        expect(feature_metrics.average_magic_link_requests_upto(:offered_at, @today - 1.week, @today)).to eq('1')
      end
    end
  end
end
