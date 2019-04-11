class Api::V1::ApplicationsController < ActionController::API
  def index
    render json: applications
  end

  def show
    if matching_application.present?
      render json: matching_application
    else
      head :not_found
    end
  end

  def make_offer
    if matching_application.present?
      render json: matching_application
    else
      head :not_found
    end
  end

  def reject
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
    JSON.parse(File.read('lib/data/fake_applications_v1.json'))
  end
end
