class UCASIntegrationCheck
  include Sidekiq::Worker

  def perform
    detect_ucas_match_file_upload_failure
  end

  def detect_ucas_match_file_upload_failure
    file_download = UCASMatching::FileDownloadCheck.new
    file_download.check
    return if file_download.success?

    Sentry.capture_exception(UCASMatchingFileDownloadFailure.new(file_download.message))
  end

  class UCASMatchingFileDownloadFailure < StandardError; end
end
