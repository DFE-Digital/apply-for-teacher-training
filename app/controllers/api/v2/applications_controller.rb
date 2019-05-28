class Api::V2::ApplicationsController < ActionController::API
  def index
    render json: { applications: applications[0..2] }
  end

  def show
    if build_application.present?
      render json: build_application
    else
      head :not_found
    end
  end

private

  def build_application
    applications.find { |app| app['id'] == params[:id] }
  end

  def applications
    JSON.parse(File.read('lib/data/fake_applications_v2.json'))
  end
end
