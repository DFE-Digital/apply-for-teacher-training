class Api::ApplicationsController < ActionController::API
  def index
    fake_applications = File.read('lib/data/fake_applications.json')
    render json: fake_applications
  end
end
