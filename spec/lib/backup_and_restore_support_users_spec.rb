require 'rails_helper'

RSpec.describe BackupAndRestoreSupportUsers do
  it 'backs up and restores support users' do
    create(:support_user)
    described_class.backup!

    SupportUser.destroy_all
    expect(SupportUser.count).to eq 0

    expect { described_class.restore! }
      .to change { SupportUser.count }.from(0).to(1)
  end

  context 'when there are no support users in the database' do
    it 'does not overwrite the backup' do
      create(:support_user)

      described_class.backup!
      SupportUser.destroy_all
      described_class.backup!
      described_class.restore!

      expect(SupportUser.count).to eq 1
    end
  end
end
