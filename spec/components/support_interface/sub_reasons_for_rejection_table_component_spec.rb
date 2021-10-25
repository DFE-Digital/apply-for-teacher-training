require 'rails_helper'

RSpec.describe SupportInterface::SubReasonsForRejectionTableComponent do
  subject(:component) do
    described_class.new(
      reason: 'candidate_behaviour_y_n',
      sub_reasons: { 'didnt_attend_interview' => ReasonsForRejectionCountQuery::Result.new(3, 2, {}) },
      total_all_time: 100,
      total_this_month: 20,
      total_for_reason_all_time: 25,
      total_for_reason_this_month: 15,
    )
  end

  describe '#sub_reason_percentage_of_reason' do
    it 'returns a formatted percentage of occurances of the subreason for a reason' do
      expect(component.sub_reason_percentage_of_reason('didnt_attend_interview')).to eq('12%')
    end

    it 'returns a formatted percentage of occurances of the subreason for a reason for the current month' do
      expect(component.sub_reason_percentage_of_reason('didnt_attend_interview', :this_month)).to eq('13.33%')
    end
  end

  describe '#sub_reason_percentage' do
    it 'returns a formatted percentage of occurances of the subreason for all rejections' do
      expect(component.sub_reason_percentage('didnt_attend_interview')).to eq('3%')
    end

    it 'returns a formatted percentage of occurances of the subreason for rejections this month' do
      expect(component.sub_reason_percentage('didnt_attend_interview', :this_month)).to eq('10%')
    end
  end

  describe '#sub_reason_count' do
    it 'returns the occurance count for the sub reason' do
      expect(component.sub_reason_count('didnt_attend_interview')).to eq(3)
    end

    it 'returns the occurance count for the sub reason for this month' do
      expect(component.sub_reason_count('didnt_attend_interview', :this_month)).to eq(2)
    end
  end
end
