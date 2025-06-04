require 'rails_helper'

RSpec.describe DataMigrations::DeleteSandboxOneLoginAccounts do
  let(:recovered_candidate) { create(:candidate, account_recovery_status: 'recovered') }
  let(:dismissed_candidate) { create(:candidate, account_recovery_status: 'dismissed') }
  let!(:one_login_auth) { create(:one_login_auth, candidate: recovered_candidate) }
  let(:account_recovery_request) { create(:account_recovery_request, candidate: recovered_candidate) }
  let!(:account_recovery_request_code) { create(:account_recovery_request_code, account_recovery_request:) }
  let!(:session) { create(:session, candidate: recovered_candidate) }

  describe '#change' do
    it 'deletes one login accounts in sandbox' do
      allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

      expect { described_class.new.change }.to change { OneLoginAuth.count }.from(1).to(0)
      .and change { Session.count }.from(1).to(0)
      .and change { AccountRecoveryRequest.count }.from(1).to(0)
      .and change { AccountRecoveryRequestCode.count }.from(1).to(0)
      .and change { recovered_candidate.reload.account_recovery_status }.from('recovered').to('not_started')
      .and change { dismissed_candidate.reload.account_recovery_status }.from('dismissed').to('not_started')
    end

    it 'does not deletes one login accounts in production' do
      allow(HostingEnvironment).to receive(:production?).and_return(true)

      expect { described_class.new.change }.not_to(change { OneLoginAuth.count })
      expect { described_class.new.change }.not_to(change { Session.count })
      expect { described_class.new.change }.not_to(change { AccountRecoveryRequest.count })
      expect { described_class.new.change }.not_to(change { AccountRecoveryRequestCode.count })
      expect { described_class.new.change }.not_to(change { recovered_candidate.reload.account_recovery_status })
      expect { described_class.new.change }.not_to(change { dismissed_candidate.reload.account_recovery_status })
    end
  end
end
