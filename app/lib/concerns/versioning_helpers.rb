module VersioningHelpers
  def extract_version(url_param)
    url_param.match(/^v(?<number>.*)/)[:number]
  end

  def major_version_number(version)
    Gem::Version.new(version).segments[0]
  end

  def minor_version_number(version)
    Gem::Version.new(version).segments[1] || 0
  end

  def version_number(version)
    "#{major_version_number(version)}.#{minor_version_number(version)}"
  end

  def api_docs_version_navigation_items
    VendorAPI::VERSIONS.keys.map do |v|
      name = case v
             when VendorAPI::VERSION
               "Current (#{v})"
             when VendorAPI.draft_version
               "Draft (#{v})"
             else
               v
             end

      { name: name, url: api_docs_versioned_reference_path(api_version: "v#{v}") }
    end
  end
end
