require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:pool_invite) { create(:pool_invite, :published, candidate:) }
    let(:provider) { pool_invite.provider }
    let(:provider2) { create(:provider) }
    let(:course) { Course.find(pool_invite.course_id) }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }

    context 'when a published pool invite exists and the candidate has not applied to the same course' do
      it 'renders the banner with course name and code saying they have not applied yet' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('Important')
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} on #{date}")
      end
    end

    context 'when a published pool invite exists and the candidate has not applied to the same course and the provider user has access to more than one provider' do
      let(:current_provider_user) { create(:provider_user, providers: [provider, provider2]) }

      it 'renders the banner with provider name, course name and code saying they have not applied yet' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('Important')
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} at #{provider.name} on #{date}")
      end
    end

    context 'when the candidate has applied to the same course through the provider and has a status visible to the provider' do
      let!(:application_choice) do
        create(
          :application_choice,
          application_form: application_form,
          course_option: create(:course_option, course:),
          provider_ids: [provider.id],
          status: 'awaiting_provider_decision',
        )
      end

      it 'renders the banner with application link text' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('This candidate has submitted an application')
        expect(result).to have_link('View application', href: "/provider/applications/#{application_choice.id}")
      end
    end

    context 'when a published pool invite exists and the candidate has a corresponding choice with a status not visible to the provider' do
      let!(:application_choice) do
        create(
          :application_choice,
          application_form: application_form,
          course_option: create(:course_option, course:),
          provider_ids: [provider.id],
          status: 'cancelled',
        )
      end

      it 'renders the banner with course name and code saying they were invited on a given date and does not link to the application' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('Important')
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} on #{date}")
        expect(result).to have_no_link('View application', href: "/provider/applications/#{application_choice.id}")
      end
    end

    context 'when no invite exists for the current provider user' do
      let(:different_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [different_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to be_blank
      end
    end

    context 'when the candidate has more than one invite from the provider user`s institutions' do
      before do
        create(:pool_invite, :published, candidate:, provider:)
      end

      it 'does not render the banner (because multiple invites banner should render)' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to be_blank
      end
    end
  end
end
