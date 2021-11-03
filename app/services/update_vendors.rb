class UpdateVendors
  def self.call(vendors_yml)
    vendors = YAML.load_file(vendors_yml)
    ActiveRecord::Base.transaction do
      Provider.where.not(vendor_id: nil).update_all(vendor_id: nil)

      vendors.each do |vendor_name, data|
        vendor = Vendor.find_or_create_by(name: vendor_name)
        data.each do |provider_code|
          provider = Provider.find_by(code: provider_code)
          provider&.update_column(:vendor_id, vendor.id)
        end
      end
    end
  end
end
