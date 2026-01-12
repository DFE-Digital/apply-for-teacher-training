require 'rails_helper'

RSpec.describe 'Support Interface - Performance pages' do
  include DfESignInHelpers

  let(:support_user) do
    create(
      :support_user,
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
    )
  end

  before do
    support_user_exists_dsi(dfe_sign_in_uid: support_user.dfe_sign_in_uid)
    get auth_dfe_support_callback_path
  end

  context 'when requesting a year when structure reasons for rejection was not implemented' do
    it 'renders not found' do
      get support_interface_reasons_for_rejection_dashboard_path(params: { year: 2022 })
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when requesting a year when structure reasons for rejection is implemented' do
    it 'renders the report' do
      get support_interface_reasons_for_rejection_dashboard_path
      expect(response).to be_ok
    end
  end
end
