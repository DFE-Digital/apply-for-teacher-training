module ShowInterview
  def show
    render json: {
      version: version_param,
      show: true
    }.to_json
  end
end
