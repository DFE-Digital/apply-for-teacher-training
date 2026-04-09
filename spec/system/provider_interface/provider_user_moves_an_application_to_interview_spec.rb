require 'rails_helper'

RSpec.describe 'Provider user moves an application to interview', feature_flag: :interview_handling do
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'Provider user has permission to manage the organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
  end

  private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    @provider_user = provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end
end
