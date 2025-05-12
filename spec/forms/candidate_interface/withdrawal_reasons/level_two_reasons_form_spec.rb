require 'rails_helper'

RSpec.describe CandidateInterface::WithdrawalReasons::LevelTwoReasonsForm do
  describe '#persist!' do
    let(:application_choice) { create(:application_choice) }

    it 'destroys old drafts' do
      draft = create(:withdrawal_reason, application_choice:)
      form = described_class.new(
        {
          level_one_reason: 'change-or-update-application-with-this-provider',
          level_two_reasons: %w[update-my-application-correct-an-error-or-add-information change-study-pattern],
        },
        application_choice:,
      )
      form.persist!
      expect { draft.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'creates multiple new drafts' do
      form = described_class.new(
        {
          level_one_reason: 'change-or-update-application-with-this-provider',
          level_two_reasons: %w[update-my-application-correct-an-error-or-add-information change-study-pattern],
        },
        application_choice:,
      )
      form.persist!
      expect(application_choice.withdrawal_reasons.pluck(:reason)).to contain_exactly(
        'change-or-update-application-with-this-provider.update-my-application-correct-an-error-or-add-information',
        'change-or-update-application-with-this-provider.change-study-pattern',
      )
    end
  end

  describe 'validations' do
    let(:application_choice) { create(:application_choice) }

    context 'when personal circumstances are selected' do
      it 'requires personal circumstances details' do
        form = described_class.new(
          {
            level_one_reason: 'do-not-want-to-train-anymore',
            level_two_reasons: %w[personal-circumstances-have-changed],
          },
          application_choice:,
        )
        expect(form).not_to be_valid
        expect(form.errors[:personal_circumstances_reasons]).to contain_exactly('Select a reason why your personal circumstances have changed')
      end

      it 'requires a personal circumstances comment when personal circumstances other is selected' do
        form = described_class.new(
          {
            level_one_reason: 'do-not-want-to-train-anymore',
            level_two_reasons: %w[personal-circumstances-have-changed],
            personal_circumstances_reasons: %w[personal-circumstances-have-changed.other],

          }, application_choice:
        )
        expect(form).not_to be_valid
        expect(form.errors[:personal_circumstances_reasons_comment]).to contain_exactly('Enter details about the change to your personal circumstances')
      end
    end

    context 'when other is selected' do
      it 'requires comment for other reason' do
        form = described_class.new(
          {
            level_one_reason: 'do-not-want-to-train-anymore',
            level_two_reasons: %w[other],
          }, application_choice:
        )
        expect(form).not_to be_valid
        expect(form.errors[:comment]).to contain_exactly('Enter details to explain the reason for withdrawing')
      end
    end

    context 'provides different presence errors depending on the first level reason' do
      it 'applying-to-another-provider' do
        form = described_class.new({ level_one_reason: 'applying-to-another-provider', level_two_reasons: [] }, application_choice:)
        expect(form).not_to be_valid
        expect(form.errors[:level_two_reasons]).to contain_exactly('Select a reason for applying to another training provider')
      end

      it 'change-or-update-application-with-this-provider' do
        form = described_class.new({ level_one_reason: 'change-or-update-application-with-this-provider', level_two_reasons: [] }, application_choice:)
        expect(form).not_to be_valid
        expect(form.errors[:level_two_reasons]).to contain_exactly('Select a reason for changing or updating your application with this training provider')
      end

      it 'apply-in-the-future' do
        form = described_class.new({ level_one_reason: 'apply-in-the-future', level_two_reasons: [] }, application_choice:)
        expect(form).not_to be_valid
        expect(form.errors[:level_two_reasons]).to contain_exactly('Select a reason for applying for teacher training in the future')
      end

      it 'do-not-want-to-train-anymore' do
        form = described_class.new({ level_one_reason: 'do-not-want-to-train-anymore', level_two_reasons: [] }, application_choice:)
        expect(form).not_to be_valid
        expect(form.errors[:level_two_reasons]).to contain_exactly('Select a reason for not wanting to train to teach anymore')
      end
    end
  end
end
