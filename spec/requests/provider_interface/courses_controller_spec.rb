require 'rails_helper'

RSpec.describe ProviderInterface::CoursesController do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { create(:course, :open, provider:) }
  let(:course_option) { create(:course_option, course:) }
  let(:wizard_attrs) { {} }
  let(:request) { put provider_interface_application_choice_course_path(application_choice) }
  let!(:application_choice) do
    create(:application_choice, :offer,
           application_form:,
           course_option:)
  end

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

    stub_model_instance_with_errors(ProviderInterface::CourseWizard, { clear_state!: nil, valid?: false, valid_for_current_step?: false }.merge(wizard_attrs))
  end

  describe 'if application choice is not in a pending state state' do
    context 'PUT update' do
      it 'responds with 302 and redirects to the application choice' do
        request

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(provider_interface_application_choice_url(application_choice))
      end

      it 'tracks validation error' do
        expect { request }.to change(ValidationError, :count).by(1)
      end
    end
  end
end
