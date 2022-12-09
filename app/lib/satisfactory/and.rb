class Satisfactory::And < Satisfactory::Connector
  def initialize(...)
    super
    @new_record = true
  end

  def same
    Satisfactory::UpstreamRecordFinder.new(upstream:)
  end
end
