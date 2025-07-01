require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, candidate:, submitted_at: 1.day.ago) }
    let(:provider) { create(:provider) }
    let(:provider2) { create(:provider) }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }

    let!(:invite1) do
      create(:pool_invite, :published, candidate:, provider:, created_at: 2.days.ago)
    end

    let!(:invite2) do
      create(:pool_invite, :published, candidate:, provider:, created_at: 1.day.ago)
    end

    let(:course1) { invite1.course }
    let(:course2) { invite2.course }

    context 'when multiple invites exist' do
      it 'renders the banner with both course names' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('This candidate was invited to apply')
        expect(result.text).to include(course1.name_and_code)
        expect(result.text).to include(course2.name_and_code)
      end
    end

    context 'when multiple invites exist and the provider user has access to more than one provider' do
      let(:current_provider_user) { create(:provider_user, providers: [provider, provider2]) }

      let(:course1) { create(:course, provider:) }
      let(:course2) { create(:course, provider: provider2) }

      let!(:invite1) { create(:pool_invite, :published, candidate:, provider:, course: course1, created_at: 2.days.ago) }
      let!(:invite2) { create(:pool_invite, :published, candidate:, provider: provider2, course: course2, created_at: 1.day.ago) }

      it 'renders the banner with both course names and the provider name' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include('This candidate was invited to apply')
        expect(result.text).to include("#{course1.name_and_code} at #{course1.provider.name}")
        expect(result.text).to include("#{course2.name_and_code} at #{course2.provider.name}")
      end
    end

    context 'when only one invite exists' do
      before { invite2.destroy }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to be_blank
      end
    end

    context 'when an invite matches an application choice' do
      let!(:application_choice) do
        create(
          :application_choice,
          application_form: application_form,
          course_option: create(:course_option, course: course1),
          provider_ids: [provider.id],
        )
      end

      it 'renders link to view application for that course' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to include(course1.name_and_code)
        expect(result).to have_link('View application', href: "/provider/applications/#{application_choice.id}")
      end
    end

    context 'when no invites belong to the current provider user`s providers' do
      let(:other_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [other_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                               ))

        expect(result.text).to be_blank
      end
    end
  end
end
