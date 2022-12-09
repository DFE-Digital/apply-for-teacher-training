class Proto::UpstreamRecordFinder
  def initialize(upstream:)
    @upstream = upstream
  end

  def method_missing(class_name)
    raise MissingUpstreamRecordError, class_name if @upstream.nil?

    case class_name.to_s
    when 'to_plan'
      @upstream.to_plan
    when @upstream.class.name.demodulize.underscore
      @with = @upstream.with(new_record: true)
      self
    else
      self.class.new(upstream: @upstream.upstream).public_send(class_name)
    end
  end

  def respond_to_missing?(...)
    true
  end

  attr_reader :with

  class MissingUpstreamRecordError < StandardError; end
end
