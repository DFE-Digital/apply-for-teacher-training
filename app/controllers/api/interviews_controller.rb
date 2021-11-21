class API::InterviewsController < API::APIController
  VERSION = '1.2'

  def index
    @interviews = Interview.limit(10)
    data = API::InterviewPresenter.new(version_param, @interviews).json

    render json: data
  end
end
