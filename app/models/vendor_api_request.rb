class VendorAPIRequest < ApplicationRecord
  belongs_to :provider, optional: true
end
