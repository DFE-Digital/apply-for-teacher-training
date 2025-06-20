require 'rails_helper'

RSpec.describe FindACandidateHelper do
  let(:application_form) { create(:application_form) }
  let(:provider_user) { create(:provider_user, :with_provider) }

  describe '#candidate_status' do
    context 'when candidate has been invited' do
      it 'returns the invited tag' do
        _invite = create(
          :pool_invite,
          :published,
          candidate: application_form.candidate,
          provider: provider_user.providers.first,
        )
        candidate_status = helper.candidate_status(
          application_form:,
          provider_user:,
        )

        expect(candidate_status).to eq(
          '<strong class="govuk-tag govuk-tag--green">Invited</strong>',
        )
      end
    end

    context 'when candidate been viewed' do
      it 'returns the viewed tag' do
        _viewed_action = create(
          :provider_pool_action,
          :viewed,
          application_form:,
          provider_user:,
        )
        candidate_status = helper.candidate_status(
          application_form:,
          provider_user:,
        )

        expect(candidate_status).to eq(
          '<strong class="govuk-tag govuk-tag--grey">Viewed</strong>',
        )
      end
    end

    context 'when candidate is new' do
      it 'returns the new tag' do
        candidate_status = helper.candidate_status(
          application_form:,
          provider_user:,
        )

        expect(candidate_status).to eq(
          '<strong class="govuk-tag">New</strong>',
        )
      end
    end

    context 'when candidate has been viewed in the previous cycle' do
      it 'returns the new tag' do
        _viewed_action_previous_cycle = create(
          :provider_pool_action,
          :viewed,
          application_form:,
          provider_user:,
          recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
        )
        candidate_status = helper.candidate_status(
          application_form:,
          provider_user:,
        )

        expect(candidate_status).to eq(
          '<strong class="govuk-tag">New</strong>',
        )
      end
    end
  end
end
