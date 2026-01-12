require 'rails_helper'

RSpec.describe ProviderInterface::NotesController do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:course) { build(:course, :open, provider:) }
  let(:course_option) { build(:course_option, course:) }
  let(:application_choice) { create(:application_choice, course_option:) }

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  describe 'validation errors' do
    it 'tracks validation errors on create', skip: 'Flakey spec' do
      stub_model_instance_with_errors(ProviderInterface::NewNoteForm, save: false)

      expect {
        post provider_interface_application_choice_notes_path(application_choice),
             params: { provider_interface_new_note_form: { message: nil } }
      }.to change(ValidationError, :count).by(1)
    end
  end
end
