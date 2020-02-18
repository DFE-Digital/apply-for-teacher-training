require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsExport do
  describe '#applications' do
    it 'returns the correct last changed dates' do
      candidate = create(:candidate, created_at: '2020-01-01')
      application_form = create(
        :application_form,
        candidate: candidate,
        support_reference: 'PJ9825',
        created_at: '2020-01-02',
        submitted_at: '2020-01-03',
      )

      create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form, updated_at: '2019-01-10')
      create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form, updated_at: '2020-01-10')

      application_form.update_columns updated_at: '2020-01-04'

      row = described_class.new.applications.first

      {
        support_reference: 'PJ9825',
        process_state: :awaiting_provider_decisions,
      }.each do |key, value|
        expect(row[key]).to eql(value)
      end

      {
        signed_up_at: '2020-01-01',
        first_signed_in_at: '2020-01-02',
        submitted_form_at: '2020-01-03',
        form_updated_at: '2020-01-04',
      }.each do |key, value|
        expect(row[key].to_s).to start_with(value), "#{key}: expected #{row[key]} to match #{value}"
      end
    end
  end
end
