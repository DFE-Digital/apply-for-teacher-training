desc 'Update provider/vendor associations from yml file'
task update_vendors: %i[environment] do
  puts 'Updating provider/vendor associations from yml file...'

  UpdateVendors.call
end
