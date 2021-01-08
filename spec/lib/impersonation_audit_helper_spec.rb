require 'rails_helper'

RSpec.describe ImpersonationAuditHelper do
  let(:service) do
    Class.new do
      include ImpersonationAuditHelper
    end
  end

  let(:provider_user) { create(:provider_user) }
  let(:support_user) { create(:support_user) }

  before { allow(Audited.audit_class).to receive(:as_user) }

  describe '#audit' do
    it 'sets :audited_user if not already set' do
      audited_store = {}
      allow(Audited).to receive(:store).and_return audited_store

      service.new.audit(provider_user) { 1 }

      expect(Audited.audit_class).to have_received(:as_user).with(provider_user)
    end

    it 'does not set :audited_user if previously set' do
      audited_store = { audited_user: create(:provider_user) }
      allow(Audited).to receive(:store).and_return audited_store

      service.new.audit(provider_user) { 1 }

      expect(Audited.audit_class).not_to have_received(:as_user)
    end

    it 'uses support user if provider user is impersonated' do
      audited_store = {}
      allow(Audited).to receive(:store).and_return audited_store
      provider_user.impersonator = support_user

      service.new.audit(provider_user) { 1 }

      expect(Audited.audit_class).to have_received(:as_user).with(support_user)
    end
  end
end
