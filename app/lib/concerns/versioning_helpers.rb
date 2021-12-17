module VersioningHelpers
  def minor_version(version)
    (version.scan(/1\.(\d+)/).flatten.first.to_i || 0)
  end

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
end
