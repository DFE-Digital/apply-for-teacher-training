module VersioningHelpers
  PRERELEASE_SUFFIX = 'pre'.freeze

  def extract_version(url_param)
    url_param.match(/^v(?<number>.*)/)[:number]
  end

  def major_version_number(version)
    Gem::Version.new(version).segments[0]
  end

  def minor_version_number(version)
    Gem::Version.new(version).segments[1] || last_minor_production_version_of_major_version(version)
  end

  def prerelease_suffix?(version)
    Gem::Version.new(version).segments[2].eql?(PRERELEASE_SUFFIX) || false
  end

  def released_versions
    ordered_versions.reject { |version| prerelease_suffix?(version) }
  end

  def full_version_number_from(version)
    "#{major_version_number(version)}.#{minor_version_number(version)}"
  end

  def prerelease?(version)
    VendorAPI::VERSIONS.key?("#{version}#{PRERELEASE_SUFFIX}")
  end

  def production_version
    ordered_versions.keys.rfind { |version| !prerelease_suffix?(version) }
  end

  def released_version
    return production_version if HostingEnvironment.production?
    return VendorAPI::VERSION if HostingEnvironment.sandbox_mode?

    development_version
  end

  def development_version
    full_version_number_from(ordered_versions.keys.last)
  end

  def ordered_versions
    VendorAPI::VERSIONS.sort_by { |version| Gem::Version.new(version[0]) }.to_h
  end

  def last_minor_production_version_of_major_version(version)
    major = major_version_number(version)

    versions = ordered_versions.keys.select do |candidate|
      major_version_number(candidate) == major && !prerelease_suffix?(candidate)
    end

    last_version = versions.last

    raise ArgumentError, "No production version found for major version #{major}" if last_version.nil?

    Gem::Version.new(last_version).segments[1]
  end
end
