require 'rails_helper'

RSpec.describe CandidateInterface::WithdrawalReasons::LevelOneReasonsForm do
  describe '#persist!' do
    let(:application_choice) { create(:application_choice) }
    let(:form) { described_class.new({ level_one_reason: 'other', comment: 'hi' }, application_choice:) }

    it 'clears old drafts' do
      old_draft = create(:withdrawal_reason, application_choice:)
      form.persist!
      expect { old_draft.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'creates a new draft withdrawal reason' do
      expect { form.persist! }.to change { WithdrawalReason.count }.by(1)
    end

    it 'updates existing withdrawal reason' do
      draft = create(:withdrawal_reason, reason: 'other', comment: 'old comment', application_choice:)
      form = described_class.new({ level_one_reason: 'other', comment: 'new comment', id: draft.id }, application_choice:)
      expect { form.persist! }.to change { draft.reload.comment }.from('old comment').to('new comment')
    end
  end

  describe '#ready_for_review?' do
    it 'only returns true if valid no supporting detail is required' do
      application_choice = create(:application_choice)

      # Not valid, no comment for 'other'
      form = described_class.new({ level_one_reason: 'other' }, application_choice:)
      expect(form.ready_for_review?).to be false

      # Needs to proceed to second step to get more detail
      form = described_class.new({ level_one_reason: 'apply-in-the-future' }, application_choice:)
      expect(form.ready_for_review?).to be false

      # Valid and does not need to go to second step
      form = described_class.new({ level_one_reason: 'other', comment: 'words' }, application_choice:)
      expect(form.ready_for_review?).to be true
    end
  end
end
