require 'rails_helper'

RSpec.describe RestructuredWorkHistory::JobComponent do
  describe 'when the start and end date are set' do
    let(:work_experience) do
      build_stubbed(
        :application_work_experience,
        start_date_unknown: true,
        start_date: Date.new(2020, 1, 1),
        end_date_unknown: false,
        end_date: Date.new(2021, 12, 31),
      )
    end

    it 'renders the start and end dates' do
      result = render_inline(described_class.new(work_experience: work_experience))
      expect(result.text.strip).to include('Jan 2020 (estimate) to Dec 2021')
    end
  end

  describe 'when only the start date is set' do
    let(:work_experience) do
      build_stubbed(
        :application_work_experience,
        start_date_unknown: false,
        start_date: Date.new(2020, 1, 1),
        end_date_unknown: nil,
        end_date: nil,
      )
    end

    it 'renders the start date correctly' do
      result = render_inline(described_class.new(work_experience: work_experience))
      expect(result.text.strip).to include('Jan 2020 to Present')
    end
  end
end
