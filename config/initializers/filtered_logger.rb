class FilteredLogger < ActiveSupport::Logger
  FILTERED_STRINGS = [
    'site_setting',
  ].freeze

  def add(severity, message = nil, progname = nil, &)
    return true if FILTERED_STRINGS.any? { |s| progname&.include? s }

    super
  end
end

ActiveRecord::Base.logger = FilteredLogger.new(STDOUT) if Rails.env.development? && ENV['RAILS_FILTER_STDOUT'].to_s == 'true'
