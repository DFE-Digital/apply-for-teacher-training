require 'rails_helper'

RSpec.describe ProviderInterface::CandidateWithdrawalReasonsDataByProvider do
  let(:provider) { create(:provider) }

  describe '#all_rows' do
    context 'when there are fewer then 10 withdrawals from unique application forms' do
      it 'returns an empty array' do
        application_forms = create_list(:application_form, 9)
        application_forms.each do |application_form|
          application_choice = create(:application_choice, :withdrawn, application_form:, provider_ids: [provider.id])
          create(:withdrawal_reason, status: 'published', application_choice:, reason: WithdrawalReason.all_reasons.sample)
        end

        expect(described_class.new(provider).all_rows).to eq []
      end
    end

    context 'when there are at least 10 withdrawals from unique application forms' do
      it 'returns data for the report' do
        create_list(:application_form, 10).each do |application_form|
          application_choice = create(:application_choice, :withdrawn, application_form:, provider_ids: [provider.id])
          create(:withdrawal_reason, status: 'published', application_choice:, reason: 'applying-to-another-provider.accepted-another-offer')
        end

        rows = described_class.new(provider).all_rows

        main_reason_row = rows.find { |row| row.reason[:text] == 'I am going to apply (or have applied) to a different training provider' }
        expect(main_reason_row.total[:text]).to eq 10

        level_two_reason_row = rows.find { |row| row.reason[:text] == 'I have accepted another offer' }
        expect(level_two_reason_row.total[:text]).to eq 10
      end
    end

    context 'where there is a mix of withdrawals before and after the candidate has accepted an offer' do
      it 'returns data for the report' do
        # rubocop:disable Style/CombinableLoops
        create_list(:application_form, 5).each do |application_form|
          accepted_application_choice = create(:application_choice, :accepted, application_form:, provider_ids: [provider.id])
          create(:withdrawal_reason, status: 'published', application_choice: accepted_application_choice, reason: 'applying-to-another-provider.accepted-another-offer')
        end

        create_list(:application_form, 5).each do |application_form|
          not_accepted_application_choice = create(:application_choice, application_form: application_form, provider_ids: [provider.id])
          create(:withdrawal_reason, status: 'published', application_choice: not_accepted_application_choice, reason: 'applying-to-another-provider.accepted-another-offer')
        end
        # rubocop:enable Style/CombinableLoops

        rows = described_class.new(provider).all_rows
        main_reason_row = rows.find { |row| row.reason[:text] == 'I am going to apply (or have applied) to a different training provider' }

        expect(main_reason_row.total[:text]).to eq 10
        expect(main_reason_row.before_accepting[:text]).to eq 5
        expect(main_reason_row.after_accepting[:text]).to eq 5

        level_two_reason_row = rows.find { |row| row.reason[:text] == 'I have accepted another offer' }
        expect(level_two_reason_row.total[:text]).to eq 10
        expect(level_two_reason_row.before_accepting[:text]).to eq 5
        expect(level_two_reason_row.after_accepting[:text]).to eq 5
      end
    end
  end
end
