require 'rails_helper'

RSpec.describe 'Support Interface - Performance pages' do
  def support_user
    @support_user ||= SupportUser.new(
      email_address: 'alice@example.com',
      dfe_sign_in_uid: 'ABC',
    )
  end

  before do
    allow(SupportUser).to receive(:load_from_session).and_return(support_user)
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
