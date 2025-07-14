require 'rails_helper'

RSpec.describe ProviderInterface::CandidateInvitedBannerComponent, type: :component do
  describe '#render' do
    let(:candidate) { create(:candidate) }
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }
    let(:other_course_option) { create(:course_option) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:application_choice) do
      create(
        :application_choice,
        :awaiting_provider_decision,
        application_form:,
        course_option:,
      )
    end
    let!(:pool_invite) { create(:pool_invite, :published, candidate:, application_form:, course:) }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }

    context 'when the provider user`s invite course and the application_choice course match' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'renders the banner' do
        result = render_inline(described_class.new(application_choice:, current_provider_user:))

        expect(result.text).to include("This candidate was invited to #{course.name_and_code} on #{date}")
      end
    end

    context 'when the provider user`s invite course and the application_choice course do not match' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'does not render the banner' do
        application_choice = create(:application_choice, course_option: other_course_option)

        result = render_inline(described_class.new(application_choice:, current_provider_user:))

        expect(result.text).to be_empty
      end
    end

    context 'when the current provider is not the one who invited the candidate' do
      let(:different_provider) { create(:provider) }
      let(:current_provider_user) { create(:provider_user, providers: [different_provider]) }

      it 'does not render the banner' do
        result = render_inline(described_class.new(application_choice:, current_provider_user:))

        expect(result.to_html).to be_blank
      end
    end

    context 'when the invite has a status of draft' do
      let(:current_provider_user) { create(:provider_user, providers: [provider]) }

      it 'does not render the banner' do
        pool_invite.update(status: 'draft')
        result = render_inline(described_class.new(application_choice:, current_provider_user:))

        expect(result.to_html).to be_blank
      end
    end
  end
end
