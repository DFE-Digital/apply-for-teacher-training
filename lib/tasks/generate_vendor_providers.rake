desc 'Generate providers for vendor sandbox'
task generate_vendor_providers: :environment do
  providers = [
      { name: 'Tribal Provider', code: 'TRIB' },
      { name: 'Ellucian Provider', code: 'ELLU' },
      { name: 'Oracle Provider', code: 'ORAC' },
      { name: 'NASBITT Provider', code: 'NASB' },
      { name: 'Unit 4 Provider', code: 'UNIT' },
      { name: 'Capita Provider', code: 'CAPI' },
      { name: 'Technology One Provider', code: 'TECH' },
      { name: 'Gordon Associates Provider', code: 'GORD' },
  ]
  providers.each do |provider|
    Provider.find_or_create_by(provider)
  end
end
