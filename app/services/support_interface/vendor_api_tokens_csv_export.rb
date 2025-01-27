module SupportInterface
  class VendorAPITokensCSVExport
    HEADERS = [
      'Provider',
      'Vendor',
      'Tokens issued',
      'Provider user email addresses',
    ].freeze

    attr_reader :vendor_tokens

    def initialize(vendor_tokens:)
      @vendor_tokens = vendor_tokens
    end

    def self.call(vendor_tokens:)
      new(vendor_tokens:).call
    end

    def call
      providers = Provider.where(id: [vendor_tokens.pluck(:provider_id).uniq])

      CSV.generate(headers: true) do |rows|
        rows << HEADERS

        providers.each do |provider|
          rows << generate_row(provider)
        end
      end
    end

  private

    def generate_row(provider)
      [
        provider.name,
        provider.vendor_name,
        provider.vendor_api_tokens.count,
        provider.provider_users&.map(&:email_address)&.join(', '),
      ]
    end
  end
end
