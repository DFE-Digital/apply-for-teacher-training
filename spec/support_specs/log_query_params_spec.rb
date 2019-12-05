require 'rails_helper'

class DummyController < ApplicationController
  include LogQueryParams
  attr_accessor :request
  def initialize
    @request = Struct.new(:query_parameters, :path_parameters).new({}, {})
  end
end

RSpec.describe LogQueryParams do
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

    it 'excludes the sign_in token from the logs' do
      allow(controller.request).to receive(:query_parameters).and_return(
        non_excluded: 'true',
        token: 'xyz',
      )

      controller.add_params_to_request_store

      expect(logged_params[:non_excluded]).not_to be_nil
      expect(logged_params[:token]).to be_nil
    end

    it 'excludes email addresses passed as query_parameters from the logs' do
      allow(controller.request).to receive(:query_parameters).and_return(
        email: 'user@example.com',
        email_address: 'user@example.com',
      )

      controller.add_params_to_request_store

      expect(logged_params[:email]).to be_nil
      expect(logged_params[:email_address]).to be_nil
    end

    it 'includes path_parameters in the logs' do
      allow(controller.request).to receive(:path_parameters).and_return(
        application_id: 15,
        controller: 'DummyController',
        action: 'index',
      )

      controller.add_params_to_request_store

      expect(logged_params[:application_id]).to eq(15)
      expect(logged_params[:controller]).to eq('DummyController')
      expect(logged_params[:action]).to eq('index')
    end
  end
end
