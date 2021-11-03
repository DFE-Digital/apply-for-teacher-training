desc 'Update provider/vendor associations from yml file'
task :update_vendors, %i[vendors_yml] => [:environment] do |_t, args|
  puts 'Updating provider/vendor associations from yml file...'

  raise 'Please specify a yml file to update vendors from.' if args[:vendors_yml].blank?

  UpdateVendors.call(args[:vendors_yml])
end
