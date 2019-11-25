require 'rails_helper'

class DummyController < ApplicationController
  include LogRequestParams
end

RSpec.describe LogRequestParams do
  context 'module inclusion' do
    it 'adds #add_params_to_request_store to the class' do
      expect(DummyController.new).to respond_to(:add_params_to_request_store)
    end

    it 'sets before_action :add_params_to_request_store' do
      expect(DummyController._process_action_callbacks.map(&:filter)).to \
        include :add_params_to_request_store
    end
  end

  context 'excludes specific params' do
    let(:controller) { DummyController.new }
    let(:logged_params) { RequestLocals.fetch(:params) { nil } }

    it 'excludes authenticity_token from the logs' do
      allow(controller).to receive(:params).and_return(
        non_excluded: 'true',
        authenticity_token: 'xyz',
      )

      controller.add_params_to_request_store
      expect(logged_params[:non_excluded]).not_to be_nil
      expect(logged_params[:authenticity_token]).to be_nil
    end

    it 'excludes any candidate_interface form from the logs' do
      allow(controller).to receive(:params).and_return(
        non_excluded: 'true',
        candidate_interface_sign_up_form: {
          email_address: 'somebody@somewhere.com',
          accept_ts_and_cs: 'true',
        },
      )

      controller.add_params_to_request_store
      expect(logged_params[:non_excluded]).not_to be_nil
      expect(logged_params[:candidate_interface_sign_up_form]).to be_nil
    end
  end
end
