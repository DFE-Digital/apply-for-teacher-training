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

    # TODO: Context blocks for when the candidate has not yet been invited to one or either of the courses (displays "They have not applied yet")
    # TODO: Context blocks for when the candidate has been invited to one or both of the courses (shows view application link(s))

    context 'when multiple invites exist' do
      it 'renders the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: false,
                               ))

        expect(result.text).to include(I18n.t('provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.heading'))
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

        expect(result.to_html).to be_blank
      end
    end

    context 'when show_provider_name is false' do
      it 'renders banner text without the provider name' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: false,
                               ))

        expect(result.text).to include(course1.name_and_code)
        expect(result.text).not_to include(provider.name)
      end
    end

    context 'when no matching invites for the current provider user exist' do
      let(:other_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [other_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(
                                 application_form:,
                                 current_provider_user:,
                                 show_provider_name: true,
                               ))

        expect(result.to_html).to be_blank
      end
    end
  end
end
