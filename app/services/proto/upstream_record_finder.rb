class Proto::UpstreamRecordFinder
  def initialize(upstream:)
    @upstream = upstream
  end

  attr_reader :upstream

  def method_missing(class_name)
    raise MissingUpstreamRecordError, class_name if upstream.nil?

    case class_name.to_s
    when 'to_plan'
      upstream.to_plan
    when upstream.class.name.demodulize.underscore
      self
    else
      self.class.new(upstream: upstream.upstream).public_send(class_name)
    end
  end

  def respond_to_missing?(...)
    true
  end

  def with(count = nil)
    Proto::And.new(upstream:, count:)
  end

  class MissingUpstreamRecordError < StandardError; end
end
