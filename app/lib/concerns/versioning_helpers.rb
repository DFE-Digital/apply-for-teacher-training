module VersioningHelpers
  PRERELEASE_SUFFIX = 'pre'.freeze

  def extract_version(url_param)
    url_param.match(/^v(?<number>.*)/)[:number]
  end

  def major_version_number(version)
    Gem::Version.new(version).segments[0]
  end

  def minor_version_number(version)
    Gem::Version.new(version).segments[1] || 0
  end

  def prerelease_suffix?(version)
    Gem::Version.new(version).segments[2].eql?(PRERELEASE_SUFFIX) || false
  end

  def released_versions
    ordered_versions.reject { |version| prerelease?(version_number(version)) }
  end

  def version_number(version)
    "#{major_version_number(version)}.#{minor_version_number(version)}"
  end

  def prerelease?(version)
    VendorAPI::VERSIONS.key?("#{version}#{PRERELEASE_SUFFIX}")
  end

  def production_version
    ordered_versions.keys.reverse.find { |version| !prerelease?(version_number(version)) }
  end

private

  def ordered_versions
    VendorAPI::VERSIONS.sort_by { |version| Gem::Version.new(version[0]) }.to_h
  end
end
