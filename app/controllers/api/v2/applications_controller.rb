class Api::V2::ApplicationsController < ActionController::API
  def index
    render json: { applications: applications }
  end

  def show
    if matching_application.present?
      render json: matching_application
    else
      head :not_found
    end
  end

private

  def matching_application
    applications.find { |app| app['id'] == params[:id] }
  end

  def applications
    JSON.parse(File.read('lib/data/fake_applications_v2.json'))
  end
end
