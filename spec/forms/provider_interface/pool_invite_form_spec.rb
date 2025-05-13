require 'rails_helper'

RSpec.describe ProviderInterface::PoolInviteForm, type: :model do
  subject(:form) do
    described_class.new(
      current_provider_user:,
      candidate:,
      pool_invite_form_params:,
    )
  end

  let(:current_provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:provider) { current_provider_user.providers.first }
  let(:candidate) { create(:candidate) }
  let(:course) { create(:course, :open, provider:) }
  let(:pool_invite_form_params) { { course_id: course.id } }

  describe '.validations' do
    it { is_expected.to validate_presence_of(:course_id) }

    context 'when a course becomes unavilable' do
      it 'returns course unavilable error' do
        course.update(exposed_in_find: false)

        expect(form.valid?).to be_falsey
        expect(form.errors[:course_id]).to eq(['Course is not available'])
      end
    end

    context 'when the candidate has been invited to the course already' do
      it 'returns course unavilable error' do
        _existing_invite = create(:pool_invite, candidate:, status: :published, course:)

        expect(form.valid?).to be_falsey
        expect(form.errors[:course_id]).to eq(['Select a different course. You have invited this person to the selected course already'])
      end
    end
  end

  describe '.build_from_invite' do
    it 'initializes the form from an invite record' do
      invite = create(:pool_invite)
      form_object = described_class.build_from_invite(
        invite: invite,
        current_provider_user:,
      )

      expect(form_object).to have_attributes(
        id: invite.id,
        course_id: invite.course_id,
        candidate: invite.candidate,
      )
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
