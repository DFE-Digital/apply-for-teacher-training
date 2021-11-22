class API::InterviewsController < API::APIController
  VERSION = '1.2'

  include ShowInterview

  VERSIONS = {
    '1.3' => ['ShowInterview'],
  }


  def index
    @interviews = Interview.limit(10)
    data = API::InterviewPresenter.new(version_param, @interviews).json

    render json: data
  end
end
