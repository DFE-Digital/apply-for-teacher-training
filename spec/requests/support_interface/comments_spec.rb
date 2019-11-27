require 'rails_helper'

RSpec.describe 'Support interface - Application Comments', type: :request do
  def create_application_form
    create :application_form
  end

  def auth_header
    {
      'HTTP_AUTHORIZATION' =>
        ActionController::HttpAuthentication::Basic.encode_credentials(
          ENV.fetch('SUPPORT_USERNAME'),
          ENV.fetch('SUPPORT_PASSWORD'),
        ),
    }
  end

  it 'creates application comments in the audit trail' do
    application_form = create_application_form

    expect {
      post(
        support_interface_application_form_comments_path(application_form_id: application_form.id),
        params: { support_interface_application_comment_form: { comment: 'foo' } },
        headers: auth_header,
      )
    }.to(change { application_form.reload.audits.count }.by(1))
  end

  it 'does not create application comment in the audit trail if comment is invalid' do
    application_form = create_application_form

    expect {
      post(
        support_interface_application_form_comments_path(application_form_id: application_form.id),
        params: { support_interface_application_comment_form: { comment: '' } },
        headers: auth_header,
      )
    }.not_to(change { application_form.reload.audits.count })
  end
end
