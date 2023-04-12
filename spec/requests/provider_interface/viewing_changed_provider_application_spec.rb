require 'rails_helper'

RSpec.describe 'Viewing application which were changed to different providers' do
  let!(:provider_user) { create(:provider_user, :with_provider, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
  let(:provider) { provider_user.providers.first }

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

  describe 'GET references, notes and timeline tab when viewing a changed app' do
    it 'restrict access and redirects to the application tab' do
      old_provider = provider
      new_provider = create(:provider, code: 'YYY')
      old_course = create(:course, provider: old_provider)
      new_course = create(:course, provider: new_provider)
      old_course_option = create(:course_option, course: old_course)
      new_course_option = create(:course_option, course: new_course)

      application_choice = create(
        :application_choice,
        :offered,
        course_option: old_course_option,
        current_course_option: new_course_option,
      )
      application_choice_id = application_choice.id

      [
        provider_interface_application_choice_references_path(application_choice_id:),
        provider_interface_application_choice_notes_path(application_choice_id:),
        provider_interface_application_choice_timeline_path(application_choice_id:),
      ].each do |path|
        get path
        expect(response).to redirect_to(
          provider_interface_application_choice_path(application_choice_id: application_choice.id),
        )
      end
    end
  end
end
