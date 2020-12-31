require 'rails_helper'

RSpec.describe FeatureMetrics, with_audited: true do
  describe '#time_to_get_references' do
    before do
      @today = Time.zone.local(2020, 12, 31, 12)
      Timecop.freeze(@today - 12.days) do
        @reference1 = create(:reference)
        CandidateInterface::RequestReference.new.call(@reference1)
        @reference2 = create(:reference)
        CandidateInterface::RequestReference.new.call(@reference2)
      end
      Timecop.freeze(@today - 9.days) do
        SubmitReference.new(reference: @reference1, send_emails: false).save!
      end
      Timecop.freeze(@today) do
        SubmitReference.new(reference: @reference2, send_emails: false).save!
      end
    end

    it 'returns the correct value for references received today' do
      expect(subject.time_to_get_references(@today.beginning_of_day, @today)).to eq(12.0)
    end

    it 'returns the correct value for references received in the past month' do
      expect(subject.time_to_get_references((@today - 1.month).beginning_of_day, @today)).to eq(7.5)
    end

    it 'returns the correct value for references received over a custom interval' do
      expect(subject.time_to_get_references((@today - 1.month).beginning_of_day, @today - 1.week)).to eq(3.0)
    end
  end
end
