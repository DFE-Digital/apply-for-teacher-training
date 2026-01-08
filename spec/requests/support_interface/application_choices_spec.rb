require 'rails_helper'

RSpec.describe 'Support interface - GET application_choice/:application_choice_id' do
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

  it 'redirects to the parent application form' do
    choice = create(:application_choice)
    form = create(:application_form, application_choices: [choice])

    get(support_interface_application_choice_path(application_choice_id: choice.id))

    expect(response).to redirect_to(support_interface_application_form_path(application_form_id: form.id))
  end
end
