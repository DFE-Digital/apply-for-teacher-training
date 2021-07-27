require 'rails_helper'

RSpec.describe 'Candidate Interface - Redirects', type: :request do
  include Devise::Test::IntegrationHelpers

  def candidate
    @candidate ||= create :candidate
  end

  before { sign_in candidate }

  describe 'Permanent redirects (301)' do
    [
      '/candidate/confirm_authentication',
      '/candidate/application/personal-details',
      '/candidate/application/personal-details/edit',
      '/candidate/application/personal-details/nationalities',
      '/candidate/application/personal-details/nationalities/edit',
      '/candidate/application/personal-details/languages',
      '/candidate/application/personal-details/languages/edit',
      '/candidate/application/personal-details/right-to-work-or-study',
      '/candidate/application/personal-details/right-to-work-or-study/edit',
      '/candidate/application/personal-details/review',
      '/candidate/application/training-with-a-disability',
      '/candidate/application/training-with-a-disability/review',
      '/candidate/application/contact-details',
      '/candidate/application/contact-details/address_type',
      '/candidate/application/contact-details/address',
      '/candidate/application/contact-details/review',
      '/candidate/application/school-experience',
      '/candidate/application/school-experience/new',
      '/candidate/application/school-experience/edit/any_id',
      '/candidate/application/school-experience/review',
      '/candidate/application/school-experience/delete/any_id',
      '/candidate/application/degrees/any_id/completion_status',
      '/candidate/application/degrees/any_id/completion_status/edit',
    ].each do |path|
      it "returns status code 301 for #{path}" do
        get path

        expect(response.status).to eq(301)
        expect(path_exists?(response.location)).to be true
      end
    end
  end

  def path_exists?(path)
    controller_params = Rails.application.routes.recognize_path(path)
    controller_params[:action] != 'not_found'
  rescue ActionController::RoutingError
    false
  end
end
