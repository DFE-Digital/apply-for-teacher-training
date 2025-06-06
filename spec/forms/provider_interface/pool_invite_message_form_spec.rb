require 'rails_helper'

RSpec.describe ProviderInterface::PoolInviteMessageForm, type: :model do
  subject(:form) do
    described_class.new(
      invite:,
      invite_message_params:,
    )
  end

  let(:invite) { create(:pool_invite) }
  let(:invite_message_params) { { invite_message:, message: } }
  let(:invite_message) { 'true' }
  let(:message) { 'custom message' }

  describe '.validations' do
    it { is_expected.to validate_presence_of(:invite_message) }

    context 'invite_message is present but message is not' do
      let(:message) { nil }

      it 'returns message error' do
        expect(form.valid?).to be_falsey
        expect(form.errors[:message]).to eq(['You must enter an invitation message'])
      end
    end

    context 'provider_message is too long' do
      let(:message) { 'message' * 40 }

      it 'returns message error' do
        expect(form.valid?).to be_falsey
        expect(form.errors[:message]).to eq(['You must enter an invitation message'])
      end
    end
  end

  describe '#save' do
    context 'when creating an invite' do
      it 'creates an invite' do
        expect { form.save }.to change(Pool::Invite, :count).by(1)
      end
    end

    context 'when updating an existing invite' do
      let(:updated_course) { create(:course, provider:) }
      let(:existing_invite) { create(:pool_invite, provider:) }
      let(:pool_invite_form_params) { { id: existing_invite.id, course_id: updated_course.id } }

      it 'updates the invite' do
        expect { form.save }.to(
          change { existing_invite.reload.course_id }.to(updated_course.id),
        )
      end
    end
  end

  describe '#available_courses' do
    it 'returns the available courses for candidate invite' do
      expect(form.available_courses).to eq([course])
    end
  end

  describe '#course' do
    it 'returns the course passed to the form' do
      expect(form.course).to eq(course)
    end
  end
end
