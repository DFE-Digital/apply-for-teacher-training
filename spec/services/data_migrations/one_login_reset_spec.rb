require 'rails_helper'

RSpec.describe DataMigrations::OneLoginReset do
  describe '#change' do
    it 'resets the account recovery status and deletes one login auths' do
      candidate = create(:candidate, account_recovery_status: :recovered)
      create(:one_login_auth)

      expect { described_class.new.change }
        .to change(OneLoginAuth, :count).from(1).to(0)
        .and change { candidate.reload.account_recovery_status }.from('recovered').to('not_started')
    end
  end
end
