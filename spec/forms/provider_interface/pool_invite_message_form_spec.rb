require 'rails_helper'

RSpec.describe ProviderInterface::PoolInviteMessageForm, type: :model do
  subject(:form) do
    described_class.new(
      invite:,
      provider_message:,
      message_content:,
    )
  end

  let(:invite) { create(:pool_invite) }
  let(:provider_message) { 'true' }
  let(:message_content) { 'custom message' }

  describe '.validations' do
    it { is_expected.to validate_inclusion_of(:provider_message).in_array([true, false]) }

    context 'provider_message is present but message is not' do
      let(:message_content) { nil }

      it 'returns message error' do
        expect(form.valid?).to be_falsey
        expect(form.errors[:message_content]).to eq(['You must enter an invitation message'])
      end
    end

    context 'provider_message is too long' do
      let(:message_content) { 'long message ' * 101 }

      it 'returns message error' do
        expect(form.valid?).to be_falsey
        expect(form.errors[:message_content]).to eq(['Invitation message must be 200 words or less'])
      end
    end
  end

  describe '#save' do
    context 'when provider message is true' do
      it 'adds message content to invite' do
        expect { form.save }.to change { invite.provider_message }.from(nil).to(true)
          .and change { invite.message_content }.from(nil).to(message_content)
      end
    end

    context 'when provider message is false' do
      let(:provider_message) { 'false' }

      it 'does not add message content to invite' do
        expect { form.save }.to change { invite.provider_message }.from(nil).to(false)
          .and(not_change { invite.message_content })
      end
    end
  end
end
