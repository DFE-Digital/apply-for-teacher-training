class UpdateVendors
  def self.call
    vendors = YAML.load_file('config/vendors.yml')
    binding.pry
    vendors.each do |vendor_name, data|
      vendor = Vendor.find_or_create_by(name: vendor_name)
      data.each do |provider_code, product_name|
        provider = Provider.find_by(code: provider_code)

        unless provider&.vendor && provider.vendor.name == vendor_name
          provider&.update_column(:vendor_id, vendor.id)
        end
      end
    end
  end
end
