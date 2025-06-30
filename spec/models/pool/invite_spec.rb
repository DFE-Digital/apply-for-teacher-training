require 'rails_helper'

RSpec.describe Pool::Invite do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:application_form) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:invited_by).class_name('ProviderUser') }
    it { is_expected.to belong_to(:course) }
    it { is_expected.to have_one(:recruitment_cycle_timetable) }
  end

  describe 'scopes' do
    describe 'with_matching_application_choices' do
      it 'returns invites where there is a matching course on a submitted application choice' do
        matched_choice = create(:application_choice, :awaiting_provider_decision)
        invite_with_matched_choice = create(:pool_invite, :sent_to_candidate, application_form: matched_choice.application_form, course: matched_choice.course)
        create(:pool_invite, :sent_to_candidate)

        expect(described_class.with_matching_application_choices).to contain_exactly(invite_with_matched_choice)
      end
    end

    describe 'without matching_application_choices' do
      it 'returns invites where there is NO matching course on a submitted application choice' do
        matched_choice = create(:application_choice, :awaiting_provider_decision)
        create(:pool_invite, :sent_to_candidate, application_form: matched_choice.application_form, course: matched_choice.course)
        invite_without_matched_choice = create(:pool_invite, :sent_to_candidate)

        expect(described_class.without_matching_application_choices).to contain_exactly(invite_without_matched_choice)
      end
    end
  end

  describe 'enums' do
    subject(:invite) { build(:pool_invite) }

    it {
      expect(invite).to define_enum_for(:status)
                          .with_values(draft: 'draft', published: 'published')
                          .with_default(:draft)
                          .backed_by_column_of_type(:string)
    }
  end

  describe '.not_sent_to_candidate' do
    it 'returns invites that have not been sent to the candidate' do
      not_sent_invite = create(:pool_invite, sent_to_candidate_at: nil)
      _sent_invite = create(:pool_invite, sent_to_candidate_at: Time.current)

      expect(described_class.not_sent_to_candidate).to contain_exactly(not_sent_invite)
    end
  end

  describe '#sent_to_candidate!' do
    it 'updates sent_to_candidate_at to current time' do
      invite = build(:pool_invite, sent_to_candidate_at: nil)

      expect {
        invite.sent_to_candidate!
      }.to change { invite.sent_to_candidate_at }.from(nil).to(be_within(1.second).of(Time.current))
    end

    it 'does not update sent_to_candidate_at if already set' do
      invite = build(:pool_invite, sent_to_candidate_at: Time.current)

      expect {
        invite.sent_to_candidate!
      }.not_to(change { invite.sent_to_candidate_at })
    end
  end

  describe '#sent_to_candidate?' do
    it 'returns true if sent_to_candidate_at is present' do
      invite = build(:pool_invite, sent_to_candidate_at: Time.current)

      expect(invite).to be_sent_to_candidate
    end

    it 'returns false if sent_to_candidate_at is nil' do
      invite = build(:pool_invite, sent_to_candidate_at: nil)

      expect(invite).not_to be_sent_to_candidate
    end
  end
end
