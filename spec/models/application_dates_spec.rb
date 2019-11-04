require 'rails_helper'

RSpec.describe ApplicationDates, type: :model do
  let(:submitted_at) { Time.new(2019, 1, 1) }

  def application_dates
    application_form = create(:application_form, submitted_at: submitted_at)
    described_class.new(application_form)
  end

  describe '#submitted_at' do
    it 'returns date that application was submitted on' do
      expect(application_dates.submitted_at).to eql(submitted_at)
    end
  end

  describe '#respond_by' do
    it 'returns date that providers will respond by' do
      expect(application_dates.respond_by.to_date).to eql(Date.new(2019, 2, 26))
    end
  end

  describe '#edit_by' do
    it 'returns date that the candidate can edit by' do
      expect(application_dates.edit_by.to_date).to eql(Date.new(2019, 1, 10))
    end
  end

  describe '#days_remaining_to_edit' do
    it 'returns number of days remaining that a candidate can edit by' do
      Timecop.travel(submitted_at) do
        expect(application_dates.days_remaining_to_edit).to eq(9)
      end

      Timecop.travel(submitted_at + 2.days) do
        expect(application_dates.days_remaining_to_edit).to eq(7)
      end
    end
  end

  describe '#form_open_to_editing?' do
    it 'returns true if the form is still open to editing' do
      Timecop.travel(submitted_at) do
        expect(application_dates).to be_form_open_to_editing
      end
    end

    it 'returns false if the form is closed to editing' do
      Timecop.travel(submitted_at + 11.days) do
        expect(application_dates).not_to be_form_open_to_editing
      end
    end
  end
end
