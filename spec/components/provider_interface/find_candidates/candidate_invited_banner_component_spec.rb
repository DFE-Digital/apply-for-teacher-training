require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::CandidateInvitedBannerComponent, type: :component do
  describe '#render' do
    let(:candidate) { create(:candidate) }
    let(:rejected_candidate_form) do
      create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    end
    let(:pool_invite) { create(:pool_invite, :published, candidate:) }
    let(:provider) { pool_invite.provider }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }
    let(:course) { Course.find(pool_invite.course_id) }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }

    it 'renders the banner when a published pool invite exists with the current provider' do
      result = render_inline(described_class.new(application_form: rejected_candidate_form, current_provider_user:))

      expect(result.text).to include('Important')
      expect(result.text).to include("This candidate was invited to #{course.name_and_code} at #{provider.name} on #{date}")
    end
  end
end
