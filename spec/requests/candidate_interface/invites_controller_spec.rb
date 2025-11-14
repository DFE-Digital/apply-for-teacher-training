require 'rails_helper'

RSpec.describe 'Invites controller' do
  before do
    sign_in_request_bypass(candidate)
  end

  let(:candidate) { create(:candidate) }

  describe 'GET /edit' do
    context 'invite not responded' do
      it 'returns ok and does not redirect' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          application_form:,
        )

        get auth_one_login_developer_callback_path
        get edit_candidate_interface_invite_path(invite)

        expect(response).to have_http_status(:ok)
        expect(response.redirection?).to be(false)
      end
    end

    context 'invite responded' do
      it 'redirect invites index page' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          candidate_decision: 'accepted',
          application_form:,
        )

        get auth_one_login_developer_callback_path
        get edit_candidate_interface_invite_path(invite)

        expect(response).to redirect_to(candidate_interface_invites_path)
      end
    end

    context 'invite does not belong to current_application' do
      it 'redirect invites index page' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          candidate_decision: 'accepted',
        )

        get auth_one_login_developer_callback_path
        get edit_candidate_interface_invite_path(invite)

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PUT /update' do
    context 'when invite is not responded' do
      it 'redirect to decline reason' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          application_form:,
        )

        get auth_one_login_developer_callback_path
        put candidate_interface_invite_path(
          invite,
          params: {
            candidate_interface_fac_invite_response_form: {
              apply_for_this_course: 'no',
            },
          },
        )

        expect(response).to redirect_to(
          new_candidate_interface_invite_decline_reason_path(invite),
        )
      end
    end

    context 'invite responded' do
      it 'redirect invites index page' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          candidate_decision: 'accepted',
          application_form:,
        )

        get auth_one_login_developer_callback_path
        put candidate_interface_invite_path(
          invite,
          params: {
            candidate_interface_fac_invite_response_form: {
              apply_for_this_course: 'no',
            },
          },
        )

        expect(response).to redirect_to(candidate_interface_invites_path)
      end
    end

    context 'invite does not belong to current_application' do
      it 'redirect invites index page' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          candidate_decision: 'accepted',
        )

        get auth_one_login_developer_callback_path
        put candidate_interface_invite_path(
          invite,
          params: {
            candidate_interface_fac_invite_response_form: {
              apply_for_this_course: 'no',
            },
          },
        )

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
