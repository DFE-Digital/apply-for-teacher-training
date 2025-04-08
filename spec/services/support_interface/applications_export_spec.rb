require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsExport, :with_audited do
  describe 'documentation' do
    before do
      application_form = create(:application_form, candidate: create(:candidate))
      create(:application_choice, application_form:)
    end

    it_behaves_like 'a data export'
  end

  describe '#applications' do
    it 'returns the correct last changed dates', :bullet, :with_audited do
      candidate = create(:candidate, created_at: '2020-01-01')
      application_form = create(
        :application_form,
        candidate:,
        support_reference: 'PJ9825',
        created_at: '2020-01-02',
        submitted_at: '2020-01-03',
      )

      create(:application_choice, :awaiting_provider_decision, application_form:, updated_at: 1.year.ago)
      create(:application_choice, :awaiting_provider_decision, application_form:, updated_at: '2020-01-10')

      time_to_freeze = 1.day.from_now.beginning_of_hour # avoid microsecond weirdness on Azure

      travel_temporarily_to(time_to_freeze) do
        application_form.update! volunteering_experience: 'I have been a volunteer!'
        create(:application_choice, :awaiting_provider_decision, application_form:)
      end

      data = Bullet.profile { described_class.new.applications }

      row = data.first

      expect(row[:candidate_id]).to eql(candidate.id)
      expect(row[:phase]).to eql('apply_1')
      expect(row[:signed_up_at].to_s).to start_with('2020-01-01')
      expect(row[:first_signed_in_at].to_s).to start_with('2020-01-02')
      expect(row[:submitted_at].to_s).to start_with('2020-01-03')
      expect(row[:support_reference]).to eql('PJ9825')
      expect(row[:application_state]).to be(:awaiting_provider_decisions)
      expect(row[:form_updated_at]).to eql(time_to_freeze)
      expect(row[:volunteering_experience_last_updated_at]).to eql(time_to_freeze)
      expect(row[:courses_last_updated_at]).to eql(time_to_freeze)
    end

    it 'only returns application data from the current cycle when current_cycle is set to true' do
      create(:application_form, :minimum_info)
      create(:application_form, :minimum_info, recruitment_cycle_year: previous_year)

      expect(described_class.new.applications('current_cycle' => true).size).to eq(1)
    end
  end
end
