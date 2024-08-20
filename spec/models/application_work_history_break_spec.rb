require 'rails_helper'

RSpec.describe ApplicationWorkHistoryBreak do
  it { is_expected.to belong_to(:breakable).touch(true) }

  describe 'auditing', :with_audited do
    it { is_expected.to be_audited.associated_with :breakable }
  end

  describe '#application_form' do
    it 'returns the application_form from breakable' do
      application_form = create(:application_form)
      work_history_break = build(
        :application_work_history_break,
        breakable: application_form,
      )

      expect(work_history_break.application_form).to eq(application_form)
    end

    context 'when breakable is not ApplicationForm' do
      it 'returns nil' do
        application_choice = create(:application_choice)
        work_history_break = build(
          :application_work_history_break,
          breakable: application_choice,
        )

        expect(work_history_break.application_form).to be_nil
      end
    end
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
