require 'rails_helper'

RSpec.describe ProviderInterface::PoolInviteMessageForm, type: :model do
  subject(:form) do
    described_class.new(
      invite:,
      provider_message:,
      message_content:,
      remember:,
    )
  end

  let(:invite) { create(:pool_invite) }
  let(:provider_message) { 'true' }
  let(:message_content) { 'custom message' }
  let(:remember) { false }

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
    context 'when provider message is true but content template exists' do
      let!(:template) do
        create(:provider_user_content_template, provider_user: invite.invited_by)
      end

      it 'adds message content to invite' do
        expect { form.save }.to change { invite.provider_message }.from(nil).to(true)
          .and change { invite.message_content }.from(nil).to(message_content)
        expect { template.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when provider message is true and user saved the message' do
      let(:remember) { true }

      it 'adds message content to invite and creates content template' do
        expect { form.save }.to change { invite.provider_message }.from(nil).to(true)
          .and change { invite.message_content }.from(nil).to(message_content)
        expect(invite.invited_by.in_use_provider_user_content_template.body).to eq(message_content)
      end
    end

    context 'when provider message is false but content template exists' do
      let(:provider_message) { 'false' }
      let!(:template) do
        create(:provider_user_content_template, provider_user: invite.invited_by)
      end

      it 'keeps the template' do
        expect { template.reload }.not_to raise_error(ActiveRecord::RecordNotFound)
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
