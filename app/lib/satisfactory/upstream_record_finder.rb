class Satisfactory::UpstreamRecordFinder
  def initialize(upstream:)
    @upstream = upstream
  end

  attr_accessor :upstream

  def find(type)
    raise MissingUpstreamRecordError, type if upstream.nil?

    if type == upstream.type
      self
    else
      self.upstream = upstream.upstream
      find(type)
    end
  end

  def with(*args, **kwargs)
    upstream.with(*args, force: true, **kwargs)
  end

  class MissingUpstreamRecordError < StandardError; end
end
