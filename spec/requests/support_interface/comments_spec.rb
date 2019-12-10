require 'rails_helper'

RSpec.describe 'Support interface - Application Comments', type: :request, with_audited: true do
  def create_application_form
    create :application_form
  end

  def support_user
    @support_user ||= SupportUser.new(
      email_address: 'alice@example.com',
      dfe_sign_in_uid: 'ABC',
    )
  end

  def set_support_user_permission
    allow(SupportUser).to receive(:load_from_session).and_return(support_user)
  end

  before do
    set_support_user_permission
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
