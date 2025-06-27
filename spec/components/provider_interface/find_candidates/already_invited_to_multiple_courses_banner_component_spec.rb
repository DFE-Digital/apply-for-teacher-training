require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, candidate:, submitted_at: 1.day.ago) }
    let(:provider) { create(:provider) }
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
                                 show_provider_name: false,
                               ))

        expect(result.text).to include('This candidate was invited to apply')
        expect(result.text).to include(course1.name_and_code)
        expect(result.text).to include(course2.name_and_code)
      end
    end

    context 'when only one invite exists' do
      before { invite2.destroy }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to be_blank
      end
    end

    context 'when show_provider_name is false' do
      it 'renders invite details without provider name' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: false,
                               ))

        expect(result.text).to include(course1.name_and_code)
        expect(result.text).not_to include(provider.name)
      end
    end

    context 'when show_provider_name is true' do
      it 'renders invite details with provider name' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to include(provider.name)
        expect(result.text).to include(course1.name_and_code)
      end
    end

    context 'when an invite matches an application choice' do
      before do
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
                                 show_provider_name: true,
                               ))

        expect(result.text).to include(course1.name_and_code)
        expect(result.text).to include('View application')
      end
    end

    context 'when no invites belong to the current provider user`s providers' do
      let(:other_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [other_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.text).to be_blank
      end
    end
  end
end
