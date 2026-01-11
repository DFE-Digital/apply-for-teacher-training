require 'rails_helper'

RSpec.describe 'Support interface - Application Comments', :with_audited do
  include DfESignInHelpers

  def create_application_form
    create(:application_form)
  end

  def support_user
    @support_user ||= SupportUser.new(
      email_address: 'alice@example.com',
      dfe_sign_in_uid: 'ABC',
    )
  end

  before do
    support_user = create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    support_user_exists_dsi(email_address: support_user.email_address)
    get auth_dfe_support_callback_path
  end

  it 'creates application comments in the audit trail' do
    application_form = create_application_form

    expect {
      post(
        support_interface_application_form_comments_path(application_form_id: application_form.id),
        params: { support_interface_application_comment_form: { comment: 'foo' } },
      )
    }.to(change { application_form.reload.audits.count }.by(1))
  end

  it 'does not create application comment in the audit trail if comment is invalid' do
    application_form = create_application_form

    expect {
      post(
        support_interface_application_form_comments_path(application_form_id: application_form.id),
        params: { support_interface_application_comment_form: { comment: '' } },
      )
    }.not_to(change { application_form.reload.audits.count })
  end
end
