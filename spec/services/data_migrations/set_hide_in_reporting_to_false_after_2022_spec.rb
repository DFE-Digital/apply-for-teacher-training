require 'rails_helper'

RSpec.describe DataMigrations::SetHideInReportingToFalseAfter2022 do
  describe '#call' do
    it 'sets hide_in_reporting false for candidate with application in 2022 or after' do
      candidate_2022 = create(
        :application_form,
        recruitment_cycle_year: 2022,
        candidate: create(:candidate, hide_in_reporting: true),
      ).candidate
      candidate_present = create(
        :application_form,
        recruitment_cycle_year: Time.zone.now.year,
        candidate: create(:candidate, hide_in_reporting: true),
      ).candidate
      candidate_before_2022 = create(
        :application_form,
        recruitment_cycle_year: 2021,
        candidate: create(:candidate, hide_in_reporting: true),
      ).candidate

      described_class.new.change
      expect(candidate_2022.reload.hide_in_reporting).to be(false)
      expect(candidate_present.reload.hide_in_reporting).to be(false)
      expect(candidate_before_2022.reload.hide_in_reporting).to be(true)
    end
  end
end
