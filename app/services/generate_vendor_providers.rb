class GenerateVendorProviders
  def self.call
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    providers = [
      { name: 'Tribal Provider', code: 'TRIB' },
      { name: 'Ellucian Provider', code: 'ELLU' },
      { name: 'Oracle Provider', code: 'ORAC' },
      { name: 'NASBITT Provider', code: 'NASB' },
      { name: 'Unit 4 Provider', code: 'UNIT' },
      { name: 'Capita Provider', code: 'CAPI' },
      { name: 'Technology One Provider', code: 'TECH' },
      { name: 'Gordon Associates Provider', code: 'GORD' },
      { name: 'University of Newcastle Upon Tyne', code: 'N21' },
      { name: 'University College Birmingham', code: 'B35' },
    ]

    providers.each do |provider|
      Provider.find_or_create_by(provider)
    end
  end
end
