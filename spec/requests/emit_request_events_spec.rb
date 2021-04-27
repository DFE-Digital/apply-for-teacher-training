require 'rails_helper'

RSpec.describe EmitRequestEvents, type: :request do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }

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

  it 'enqueues request event data with sidekiq worker' do
    Sidekiq::Testing.fake! do
      expect {
        get provider_interface_applications_path
      }.to change(SendRequestEventsToBigquery.jobs, :size).by(1)

      worker_args = SendRequestEventsToBigquery.jobs.first['args']

      expect(worker_args.first['request_path']).to eq('/provider/applications')
      expect(worker_args.first['request_method']).to eq('GET')
      expect(worker_args.first['environment']).to eq('test')
      expect(worker_args.first['namespace']).to eq('provider_interface')
      expect(worker_args.first['user_id']).to eq(provider_user.id)
    end
  end
end
