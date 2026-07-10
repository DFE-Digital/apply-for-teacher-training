require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'inactive_user_prompt' do
    let(:date) { provider_user.last_signed_in_at }
    let(:email) { described_class.inactive_user_prompt(provider_user, date) }

    context 'with one provider' do
      let(:providers) { [build_stubbed(:provider, code: 'LMN', name: 'UCL')] }
      let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', last_signed_in_at: Date.new(2025, 7, 10), providers:) }

      it_behaves_like(
        'a mail with subject and content',
        'Your Manage account will be deleted on 10 July if you do not sign in - manage teacher training applications',
        'providers list' => 'If your account is deleted, you will no longer be able to manage teacher training applications for UCL.',
      )
    end

    context 'with two providers' do
      let(:providers) do
        [
          build_stubbed(:provider, code: 'LMN', name: 'UCL'),
          build_stubbed(:provider, code: 'OPQ', name: "King's College London"),
        ]
      end

      let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', last_signed_in_at: Date.new(2025, 7, 10), providers:) }

      it_behaves_like(
        'a mail with subject and content',
        'Your Manage account will be deleted on 10 July if you do not sign in - manage teacher training applications',
        'providers list' => "If your account is deleted, you will no longer be able to manage teacher training applications for UCL or King's College London.",
      )
    end

    context 'with three providers' do
      let(:providers) do
        [
          build_stubbed(:provider, code: 'LMN', name: 'UCL'),
          build_stubbed(:provider, code: 'OPQ', name: "King's College London"),
          build_stubbed(:provider, code: 'RST', name: 'Birkbeck'),
        ]
      end

      let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', last_signed_in_at: Date.new(2025, 7, 10), providers:) }

      it_behaves_like(
        'a mail with subject and content',
        'Your Manage account will be deleted on 10 July if you do not sign in - manage teacher training applications',
        'providers list' => "If your account is deleted, you will no longer be able to manage teacher training applications for UCL, King's College London or Birkbeck.",
      )
    end
  end
end
