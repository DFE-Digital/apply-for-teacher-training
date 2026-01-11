require 'rails_helper'

RSpec.describe 'Support interface - POST /support/applications/:application_id/references/:reference_id/feedback' do
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

  def set_support_user_permission
    allow(SupportUser).to receive(:load_from_session).and_return(support_user)
  end

  it 'does not change the selected attribute' do
    set_support_user_permission

    application_form = create(:application_form)
    reference = create(:reference, application_form:, selected: true)

    post(
      support_interface_application_form_update_reference_feedback_path(
        support_interface_application_forms_edit_reference_feedback_form: {
          feedback: 'some feedback',
          audit_comment: 'ticket',
          send_emails: 'false',
          confidential: 'true',
        },
        application_form_id: application_form.id,
        reference_id: reference.id,
      ),
    )

    expect(reference.reload.selected).to be(true)
    expect(response).to redirect_to(
      support_interface_application_form_path(application_form),
    )
  end
end
