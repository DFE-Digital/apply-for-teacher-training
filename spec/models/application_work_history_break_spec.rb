require 'rails_helper'

RSpec.describe ApplicationWorkHistoryBreak do
  it { is_expected.to belong_to(:application_form).touch(true).optional }
  it { is_expected.to belong_to(:breakable) }

  describe 'auditing', :with_audited do
    it { is_expected.to be_audited.associated_with :application_form }
  end

  describe '#length' do
    it 'calculates the length of the break' do
      work_history_break = build(
        :application_work_history_break,
        start_date: Date.new(2020, 8, 14),
        end_date: Date.new(2024, 8, 14),
      )

      expect(work_history_break.length).to eq(47)
    end
  end
end
