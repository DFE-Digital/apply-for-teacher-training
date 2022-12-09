class SampleApplicationsFactory
  def self.candidate
    new.candidate
  end

  def initialize
    @candidates = []
  end

  def candidate
    Factory::Candidate.new(upstream: self).tap do |candidate|
      @candidates << candidate
    end
  end

  def create
    if (cs = @candidates.map(&:create_self)).size == 1
      cs.first
    else
      cs
    end
  end

  def to_plan
    {
      candidates: @candidates.map(&:build_plan),
    }
  end

  def upstream
    nil
  end
end
