require 'rails_helper'

RSpec.describe 'Support interface - Application Comments', type: :request do
  def create_application_form
    create :application_form
  end

  it 'creates application comments in the audit trail attributed to the authenticated user' do
    application_form = create_application_form

    expect {
      post(
        support_interface_application_form_comments_path(application_form_id: application_form.id),
        params: { support_interface_application_comment_form: { comment: 'foo' } },
      )
    }.to(change { application_form.reload.audits.count }).by(1)
  end
end
