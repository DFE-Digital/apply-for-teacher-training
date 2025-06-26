require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::CandidateInvitedBannerComponent, type: :component do
  describe '#render' do
    let(:candidate) { create(:candidate) }
    let(:application_form) do
      create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    end
    let(:pool_invite) { create(:pool_invite, :published, candidate:) }
    let(:provider) { pool_invite.provider }
    let(:course) { Course.find(pool_invite.course_id) }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }

    context 'when a published pool invite exists with the current provider' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'renders the banner' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.text).to include('Important')
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} at #{provider.name} on #{date}")
      end
    end

    context 'when the current provider is not the one who invited the candidate' do
      let(:different_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [different_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.to_html).to be_blank
      end
    end
  end
end
