class ApplicationResponseCache < ApplicationRecord
  belongs_to :application_choice

  def stale?
    response != VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
  end

  def refresh!
    update!(response: VendorAPI::SingleApplicationPresenter.new(application_choice).as_json)
  end
end
