require 'rails_helper'

class DummyController < ApplicationController
  include RequestQueryParams
  attr_accessor :request
  def initialize
    @request = Struct.new(:query_parameters, :path_parameters).new({}, {})
  end
end

RSpec.describe RequestQueryParams do
  context 'excludes specific params' do
    let(:controller) { DummyController.new }
    let(:logged_params) { controller.request_query_params }

    it 'excludes the sign_in token from the logs' do
      allow(controller.request).to receive(:query_parameters).and_return(
        non_excluded: 'true',
        token: 'xyz',
      )

      expect(logged_params[:non_excluded]).not_to be_nil
      expect(logged_params[:token]).to be_nil
    end

    it 'excludes email addresses passed as query_parameters from the logs' do
      allow(controller.request).to receive(:query_parameters).and_return(
        email: 'user@example.com',
        email_address: 'user@example.com',
      )

      expect(logged_params[:email]).to be_nil
      expect(logged_params[:email_address]).to be_nil
    end

    it 'includes path_parameters in the logs' do
      allow(controller.request).to receive(:path_parameters).and_return(
        application_id: 15,
        controller: 'DummyController',
        action: 'index',
      )

      expect(logged_params[:application_id]).to eq(15)
      expect(logged_params[:controller]).to eq('DummyController')
      expect(logged_params[:action]).to eq('index')
    end
  end
end
