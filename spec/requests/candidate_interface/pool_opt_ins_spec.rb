require 'rails_helper'

RSpec.describe 'pool opt ins' do
  before do
    sign_in_request_bypass(candidate)
  end

  let(:candidate) { create(:candidate) }

  describe 'GET /candidate/preferences-opt-in/show' do
    context 'published_preference exists' do
      it 'returns ok' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, application_form:)

        get auth_one_login_developer_callback_path
        get show_candidate_interface_pool_opt_ins_path

        expect(response).to have_http_status(:ok)
      end
    end

    context 'published_preference is opt_out' do
      it 'redirects to candidate invites page' do
        application_form = create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )
        create(:candidate_preference, :opt_out, application_form:)

        get auth_one_login_developer_callback_path
        get show_candidate_interface_pool_opt_ins_path

        expect(response).to redirect_to(candidate_interface_invites_path)
      end
    end

    context 'no published_preference' do
      it 'redirects to candidate invites page' do
        create(
          :application_form,
          :completed,
          candidate:,
          submitted_application_choices_count: 1,
        )

        get auth_one_login_developer_callback_path
        get show_candidate_interface_pool_opt_ins_path

        expect(response).to redirect_to(candidate_interface_invites_path)
      end
    end
  end
end
