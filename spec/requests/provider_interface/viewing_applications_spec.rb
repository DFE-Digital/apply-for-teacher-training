require 'rails_helper'

RSpec.describe 'Viewing applications', type: :request do
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
    allow(DfESignInUser).to receive(:load_from_session)
      .and_return(
        DfESignInUser.new(
          email_address: provider_user.email_address,
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: provider_user.first_name,
          last_name: provider_user.last_name,
        ),
      )
  end

  describe 'GET show with application_choice_id for an application to my provider' do
    it 'responds with 200' do
      application_choice = create(
        :submitted_application_choice,
        course_option: create(:course_option, course: create(:course, provider: provider)),
      )
      get provider_interface_application_choice_path(application_choice_id: application_choice.id)

      expect(response.status).to eq(200)
    end
  end

  describe 'GET show with invalid application_choice_id param' do
    it 'responds with 404' do
      get provider_interface_application_choice_path(application_choice_id: 666)

      expect(response.status).to eq(404)
    end
  end

  describe 'GET show with application_choice_id param for an application to another provider' do
    it 'responds with 404' do
      application_choice = create(:application_choice)
      get provider_interface_application_choice_path(application_choice_id: application_choice.id)

      expect(response.status).to eq(404)
    end
  end
end
