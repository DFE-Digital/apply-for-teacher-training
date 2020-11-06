class HeartbeatController < ActionController::API
  def ping
    render body: "PONG"
  end

  def healthcheck
    checks = {
      teacher_training_api: api_alive?,
    }

    render status: (checks.values.all? ? :ok : :service_unavailable),
           json: {
             checks: checks,
           }
  end

  def sha
    render json: { sha: commit_sha }
  end

private

  def api_alive?
    response = HTTParty.get("#{Settings.teacher_training_api.base_url}/healthcheck")
    response.success?
  rescue StandardError
    false
  end

  def commit_sha
    File.read(commit_sha_path).strip
  end

  def commit_sha_path
    Rails.root.join(Settings.commit_sha_file)
  end
end
