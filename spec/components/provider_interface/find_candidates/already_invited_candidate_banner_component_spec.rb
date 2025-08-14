require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:provider) { create(:provider) }
    let(:provider2) { create(:provider) }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }
    let(:pool_invite) { create(:pool_invite, :published, candidate:, application_form:, provider:) }
    let(:course) { pool_invite.course }
    let(:date) { pool_invite.created_at.to_fs(:govuk_date) }
    let(:declined_invite) { create(:pool_invite, :published, candidate:, application_form:, provider:, candidate_decision: 'declined') }

    subject(:result) do
      render_inline(described_class.new(
                      application_form:,
                      current_provider_user:,
                    ))
    end

    context 'when exactly one matching published invite exists and candidate has not applied to the course' do
      before { pool_invite }

      it 'renders the banner with course name and date' do
        expect(result.text).to include('Important')
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} on #{date}")
      end
    end

    context 'when candidate has applied to the invited course with a visible status' do
      let!(:application_choice) do
        create(
          :application_choice,
          application_form:,
          course_option: create(:course_option, course: pool_invite.course),
          status: 'awaiting_provider_decision',
        )
      end

      before { pool_invite }

      it 'renders the banner with an application link' do
        expect(result.text).to include('This candidate has submitted an application')
        expect(result).to have_link('View application', href: "/provider/applications/#{application_choice.id}")
      end
    end

    context 'when candidate applied to the course but status is not visible to provider' do
      let!(:application_choice) do
        create(
          :application_choice,
          application_form:,
          course_option: create(:course_option, course: pool_invite.course),
          status: 'cancelled',
        )
      end

      before { pool_invite }

      it 'renders banner without application link' do
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} on #{date}")
        expect(result).to have_no_link('View application')
      end
    end

    context 'when current provider user has access to multiple providers' do
      let(:current_provider_user) { create(:provider_user, providers: [provider, provider2]) }

      before { pool_invite }

      it 'renders the banner including the provider name' do
        expect(result.text).to include("This candidate was invited to #{course.name_and_code} at #{provider.name} on #{date}")
      end
    end

    context 'when there is no matching invite for the application_form' do
      let(:unrelated_invite) { create(:pool_invite, :published) }

      it 'does not render the banner' do
        expect(result.text).to be_blank
      end
    end

    context 'when more than one invite exists for the current application_form and provider' do
      before do
        create(:pool_invite, :published, candidate:, application_form:, provider:)
        create(:pool_invite, :published, candidate:, application_form:, provider:)
      end

      it 'does not render the banner' do
        expect(result.text).to be_blank
      end
    end

    context 'when the candidate has declined the invite' do
      before do
        create(:pool_invite_decline_reason, invite_id: declined_invite.id, reason: 'provider_not_right')
      end

      it 'renders the declined header and text' do
        expect(result.text).to include("This candidate does not want to apply for #{declined_invite.course.name_and_code}")
        expect(result.text).to include('They selected the reason: this course training provider is not right for me')
      end
    end

    context 'when the candidate has declined the invite with "another reason" and a comment' do
      before do
        create(:pool_invite_decline_reason,
               invite_id: declined_invite.id,
               reason: 'other',
               comment: 'I have decided to pursue another course')
      end

      it 'renders the reason with the comment in quotes' do
        expect(result.text).to include("This candidate does not want to apply for #{declined_invite.course.name_and_code}")
        expect(result.text).to include('They selected the reason: another reason - "I have decided to pursue another course"')
      end
    end

    context 'when the candidate has declined the invite with "another reason" and no comment' do
      before do
        create(:pool_invite_decline_reason,
               invite_id: declined_invite.id,
               reason: 'other')
      end

      it 'renders only the reason' do
        expect(result.text).to include("This candidate does not want to apply for #{declined_invite.course.name_and_code}")
        expect(result.text).to include('They selected the reason: another reason')
      end
    end
  end
end
