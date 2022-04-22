namespace :version do
  namespace :vendor_api do
    desc 'Displays VendorAPI versions across all environments'
    task latest: :environment do
      STDOUT.puts <<~LATEST_VERSIONS
        =========================
        Vendor API latest version
        -------------------------
        Production: v#{VendorAPI.production_version}
        Sandbox: v#{VendorAPI::VERSION}
        QA: v#{VendorAPI.development_version}
        -------------------------
      LATEST_VERSIONS
    end

    desc 'Display details of VendorAPI version change classes'
    task :changes, %i[version] => :environment do |_, args|
      specified_version = args.fetch(:version, nil)
      VendorAPI.ordered_versions.each do |version, version_changes|
        next if version.present? && specified_version != VendorAPI.full_version_number_from(version)

        STDOUT.puts "Version v#{version}\n\n"
        version_changes.each do |change_class|
          changes = change_class.new
          STDOUT.puts changes.class.name
          STDOUT.puts changes.description
          changes.summary.each do |key, value|
            STDOUT.puts "\t#{key}"
            STDOUT.puts "\t\t#{value.join(', ')}" if value.any?
          end
          STDOUT.puts ''
        end
      end
    end
  end
end
