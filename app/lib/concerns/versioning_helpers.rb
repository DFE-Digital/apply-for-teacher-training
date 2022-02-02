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
    VendorAPI::VERSIONS.keys.select { |v| v <= VendorAPI::VERSION }.sort.map do |v|
      { name: v, url: api_docs_versioned_reference_path(api_version: "v#{v}") }
    end
  end

  def render_api_docs_version_navigation?
    api_docs_version_navigation_items.size > 1
  end
end
