class Support::DeleteOldVendorAPIRequestsWorker < ApplicationJob
  def perform
    VendorAPIRequestV2.where('created_at < ?', 3.months.ago).delete_all
  end
end
