require 'rails_helper'

RSpec.describe 'Support interface - GET application_choice/:application_choice_id' do
  def support_user
    @support_user ||= SupportUser.new(
      email_address: 'alice@example.com',
      dfe_sign_in_uid: 'ABC',
    )
  end

  def set_support_user_permission
    allow(SupportUser).to receive(:load_from_session).and_return(support_user)
  end

  it 'redirects to the parent application form' do
    set_support_user_permission

    choice = create(:application_choice)
    form = create(:application_form, application_choices: [choice])

    get(support_interface_application_choice_path(application_choice_id: choice.id))

    expect(response).to redirect_to(support_interface_application_form_path(application_form_id: form.id))
  end
end
