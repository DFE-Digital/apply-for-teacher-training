class Proto::And < Proto::Connector
  def initialize(...)
    super
    @new_record = true
  end

  def same
    Proto::UpstreamRecordFinder.new(upstream:)
  end
end
