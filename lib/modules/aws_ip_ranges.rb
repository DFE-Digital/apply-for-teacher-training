module AWSIpRanges
  # Used based on this AWS instruction: https://forums.aws.amazon.com/ann.jspa?annID=2051
  PATH = 'https://ip-ranges.amazonaws.com/ip-ranges.json'.freeze
  COMPATIBLE_REGIONS = %w[GLOBAL eu-west-2].freeze
  ResponseError = Class.new(StandardError)

  def self.cloudfront_ips
    uri = URI(PATH)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', read_timeout: 10, open_timeout: 5) do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      raise ResponseError, "#{response.code} - #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      parse_json_for_ips(response.body)
    end
  rescue StandardError => e
    Raven.capture_exception(e)
    []
  end

  def self.parse_json_for_ips(response)
    aws_ip_ranges = JSON.parse(response)

    aws_ip_ranges['prefixes'].each_with_object([]) do |record, arr|
      next unless COMPATIBLE_REGIONS.include?(record['region']) && record['service'] == 'CLOUDFRONT'

      arr << record['ip_prefix']
    end
  end
end
