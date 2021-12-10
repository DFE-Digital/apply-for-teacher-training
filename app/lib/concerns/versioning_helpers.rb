module VersioningHelpers
  def minor_version(version)
    (version.scan(/1\.(\d+)/).flatten.first.to_i || 0)
  end
end
