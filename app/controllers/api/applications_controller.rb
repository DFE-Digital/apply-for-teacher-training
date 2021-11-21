class API::ApplicationsController < API::APIController
  VERSION = '1.1'

  def index
    @applications = ApplicationChoice.limit(10)
    data = API::ApplicationPresenter.new(version_param, @applications).json

    render json: data
  end
end
