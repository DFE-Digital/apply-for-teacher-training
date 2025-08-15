require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, candidate:, submitted_at: 1.day.ago) }
    let(:provider) { create(:provider) }
    let(:provider2) { create(:provider) }

    context 'when multiple invites exist for providers the user has access to' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      let!(:course1) { create(:course, provider:) }
      let!(:course2) { create(:course, provider:) }

      let!(:invite1) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1, created_at: 2.days.ago)
      end

      let!(:invite2) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course2, created_at: 1.day.ago)
      end

      it 'renders the banner with both course names' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.text).to include('This candidate was invited to apply')
        expect(result.text).to include(course1.name_and_code)
        expect(result.text).to include(course2.name_and_code)
      end
    end

    context 'when provider user has access to multiple providers and invites are from both' do
      let(:current_provider_user) { create(:provider_user, providers: [provider, provider2]) }

      let!(:course1) { create(:course, provider:) }
      let!(:course2) { create(:course, provider: provider2) }

      let!(:invite1) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1, created_at: 2.days.ago)
      end

      let!(:invite2) do
        create(:pool_invite, :published, candidate:, application_form:, provider: provider2, course: course2, created_at: 1.day.ago)
      end

      it 'renders the banner with both course and provider names' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include("#{course1.name_and_code} at #{course1.provider.name}")
        expect(result.text).to include("#{course2.name_and_code} at #{course2.provider.name}")
      end
    end

    context 'when only one invite exists' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      let!(:course1) { create(:course, provider:) }

      let!(:invite1) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1)
      end

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to be_blank
      end
    end

    context 'when an invite matches a visible application choice' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      let!(:course1) { create(:course, provider:) }
      let!(:course2) { create(:course, provider:) }

      let!(:invite1) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1)
      end

      let!(:invite2) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course2)
      end

      let!(:application_choice) do
        create(:application_choice,
               application_form:,
               course_option: create(:course_option, course: course1),
               provider_ids: [provider.id],
               status: 'awaiting_provider_decision')
      end

      it 'renders a link to view the matching application' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include(course1.name_and_code)
        expect(result).to have_link('View application', href: "/provider/applications/#{application_choice.id}")
      end
    end

    context 'when invites do not belong to providers the user has access to' do
      let(:other_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [other_provider]) }

      let!(:course1) { create(:course, provider:) }
      let!(:course2) { create(:course, provider:) }

      let!(:invite1) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1)
      end

      let!(:invite2) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course2)
      end

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to be_blank
      end
    end

    context 'when an invite has been declined' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      let!(:course1) { create(:course, provider:) }
      let!(:course2) { create(:course, provider:) }

      let!(:invite1) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1, candidate_decision: 'declined')
      end

      let!(:invite2) do
        create(:pool_invite, :published, candidate:, application_form:, provider:, course: course2)
      end

      it 'states that the candidate declined' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('They declined the invitation')
        expect(result.text).to include(course1.name_and_code)
      end
    end
  end
end
