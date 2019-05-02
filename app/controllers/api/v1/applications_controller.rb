class Api::V1::ApplicationsController < ActionController::API
  def index
    render json: applications
  end

  def show
    if build_application.present?
      render json: build_application
    else
      head :not_found
    end
  end

  def make_offer
    if build_application.present?
      render json: build_application
    else
      head :not_found
    end
  end

  def reject
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
    JSON.parse(File.read('lib/data/fake_applications_v1.json'))
  end
end
