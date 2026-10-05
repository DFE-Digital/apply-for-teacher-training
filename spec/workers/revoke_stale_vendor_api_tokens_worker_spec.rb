require 'rails_helper'

RSpec.describe RevokeStaleVendorAPITokensWorker, :with_audited do
  describe '#perform' do
    context 'production' do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(true)
      end

      it 'revokes tokens that were used over three months ago' do
        token = create(
          :vendor_api_token,
          :with_random_token,
          last_used_at: 3.months.ago - 1.minute,
        )
        original_hashed_token = token.hashed_token

        described_class.new.perform

        token.reload

        expect(token.discarded?).to be(true)
        expect(token.audits.last.comment).to eq 'Revoked because of inactivity'
        expect(token.hashed_token).not_to eq original_hashed_token
      end

      it 'revokes unused tokens created over three months ago' do
        token = create(
          :vendor_api_token,
          :with_random_token,
          last_used_at: nil,
          created_at: 3.months.ago - 1.minute,
        )
        original_hashed_token = token.hashed_token

        described_class.new.perform

        token.reload

        expect(token.discarded?).to be(true)
        expect(token.audits.last.comment).to eq 'Revoked because of inactivity'
        expect(token.hashed_token).not_to eq original_hashed_token
      end

      it 'does not revoke active tokens' do
        used_recently = create(
          :vendor_api_token,
          :with_random_token,
          last_used_at: 2.months.ago,
          created_at: 3.months.ago - 1.minute,
        )
        original_hashed_token = used_recently.hashed_token

        created_recently = create(
          :vendor_api_token,
          :with_random_token,
          last_used_at: nil,
          created_at: 2.months.ago,
        )

        described_class.new.perform

        expect(used_recently.reload.discarded?).to be(false)
        expect(created_recently.reload.discarded?).to be(false)
        expect(original_hashed_token).to eq(used_recently.hashed_token)
      end
    end

    context 'not production' do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(false)
      end

      it 'does not revoke any tokens' do
        token = create(
          :vendor_api_token,
          :with_random_token,
          last_used_at: 3.months.ago - 1.minute,
        )

        described_class.new.perform

        token.reload

        expect(token.discarded?).to be(false)
      end
    end
  end
end
