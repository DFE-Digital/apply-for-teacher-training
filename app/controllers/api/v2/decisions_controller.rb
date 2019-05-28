class Api::V2::DecisionsController < ActionController::API
  def index
    if matching_application
      render json: { decisions: matching_application['decisions'] }
    else
      head :not_found
    end
  end

private

  def matching_application
    applications.find { |app| app['id'] == params[:application_id] }
  end

  def applications
    JSON.parse(File.read('lib/data/fake_applications_v2.json'))
  end
end
