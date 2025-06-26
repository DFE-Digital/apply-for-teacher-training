require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:pool_invite) { create(:pool_invite, :published, candidate:) }
    let(:provider) { pool_invite.provider }
    let(:course) { Course.find(pool_invite.course_id) }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }

    context 'when a published pool invite exists and the candidate has not applied to the same course' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'renders the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to include('Important')
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} at #{provider.name} on #{date}")
      end
    end

    context 'when the candidate has already applied to the same course through the provider' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      before do
        create(
          :application_choice,
          application_form: application_form,
          course_option: create(:course_option, course: course),
          provider_ids: [provider.id],
        )
      end

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.to_html).to be_blank
      end
    end

    context 'when no invite exists for the current provider user' do
      let(:different_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [different_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.to_html).to be_blank
      end
    end

    context 'when show_provider_name is true' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'includes the provider name in the banner text' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to include(provider.name)
      end
    end

    context 'when show_provider_name is false' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'does not include the provider name in the banner text' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: false,
                               ))

        expect(result.text).not_to include(provider.name)
      end
    end
  end
end
