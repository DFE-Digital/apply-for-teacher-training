require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:pool_invite) { create(:pool_invite, :published, candidate:) }
    let(:provider) { pool_invite.provider }
    let(:course) { Course.find(pool_invite.course_id) }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }

    context 'when a published pool invite exists and the candidate has not applied to the same course' do
      it 'renders the banner with course name and code saying they have not applied yet' do
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
      before do
        create(
          :application_choice,
          application_form: application_form,
          course_option: create(:course_option, course: course),
          provider_ids: [provider.id],
        )
      end

      it 'renders the banner with application link text' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to include('The candidate has submitted an application.')
        expect(result.text).to include('View application')
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

        expect(result.text).to be_blank
      end
    end

    context 'when the candidate has more than one invite the candidate from the provider user`s institutions' do
      before do
        create(:pool_invite, :published, candidate:, provider:)
      end

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to be_blank
      end
    end

    context 'when show_provider_name is true' do
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
