require 'rails_helper'

RSpec.describe CandidateInterface::WithdrawalReasons::LevelTwoReasonsBuilder do
  describe '#form_attributes' do
    let(:application_choice) { create(:application_choice) }

    context 'when no draft withdrawal reasons exist' do
      it 'returns empty / nil values for all attributes other than level_one_reason' do
        builder = described_class.new('change-or-update-application-with-this-provider', application_choice)
        expect(builder.form_attributes)
          .to eq({
            level_one_reason: 'change-or-update-application-with-this-provider',
            level_two_reasons: [],
            personal_circumstances_reasons: [],
            comment: nil,
            personal_circumstances_reasons_comment: nil,
          })
      end
    end

    context 'when reasons exist but with a different level one reason' do
      it 'returns empty / nil values for all attributes other than level_one_reason' do
        create(:withdrawal_reason, reason: 'other', application_choice:)
        builder = described_class.new('change-or-update-application-with-this-provider', application_choice)
        expect(builder.form_attributes)
          .to eq({
            level_one_reason: 'change-or-update-application-with-this-provider',
            level_two_reasons: [],
            personal_circumstances_reasons: [],
            comment: nil,
            personal_circumstances_reasons_comment: nil,
          })
      end
    end

    context 'when there are existing reasons with matching level_one_reasons' do
      it 'returns the correct level one and level two reasons' do
        create(
          :withdrawal_reason,
          reason: 'change-or-update-application-with-this-provider.change-study-pattern',
          application_choice:,
        )

        create(
          :withdrawal_reason,
          reason: 'change-or-update-application-with-this-provider.other',
          comment: 'This is a comment about updating my application',
          application_choice:,
        )

        builder = described_class.new('change-or-update-application-with-this-provider', application_choice)
        expect(builder.form_attributes).to eq(
          {
            level_one_reason: 'change-or-update-application-with-this-provider',
            level_two_reasons: %w[change-study-pattern other],
            personal_circumstances_reasons: [],
            comment: 'This is a comment about updating my application',
            personal_circumstances_reasons_comment: nil,
          },
        )
      end
    end

    context 'when there are existing, relevant personal circumstances related reasons' do
      it 'returns the correct personal circumstances reasons' do
        create(
          :withdrawal_reason,
          reason: 'apply-in-the-future.personal-circumstances-have-changed.other',
          comment: 'My personal circumstances have changed, this is a comment about them.',
          application_choice:,
        )
        create(
          :withdrawal_reason,
          reason: 'apply-in-the-future.personal-circumstances-have-changed.concerns-about-cost-of-doing-course',
          application_choice:,
        )
        builder = described_class.new('apply-in-the-future', application_choice)
        expect(builder.form_attributes).to eq(
          {
            level_one_reason: 'apply-in-the-future',
            level_two_reasons: %w[personal-circumstances-have-changed],
            personal_circumstances_reasons: %w[personal-circumstances-have-changed.concerns-about-cost-of-doing-course personal-circumstances-have-changed.other],
            comment: nil,
            personal_circumstances_reasons_comment: 'My personal circumstances have changed, this is a comment about them.',
          },
        )
      end
    end
  end
end
