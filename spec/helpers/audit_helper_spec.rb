require 'rails_helper'

RSpec.describe AuditHelper, type: :helper do
  describe 'change_by_support?' do
    let(:user) { nil }
    let(:username) { nil }
    let(:audit) do
      create(
        :application_choice_audit,
        user: user,
        username: username,
      )
    end

    subject { change_by_support?(audit) }

    context 'user is a SupportUser' do
      let(:user) { build_stubbed(:support_user) }

      it { is_expected.to eq(true) }
    end

    context 'change was made in the rails console' do
      let(:username) { 'Developer via the Rails console' }

      it { is_expected.to eq(true) }
    end

    context 'change was made by a different user' do
      let(:username) { 'Ghost man' }

      it { is_expected.to eq(false) }
    end
  end
end
