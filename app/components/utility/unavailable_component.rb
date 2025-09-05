class UnavailableComponent < ApplicationComponent
  def initialize(title:, reason: nil, lead_in: nil, alternatives: [])
    @title = title
    @reason = reason
    @lead_in = lead_in
    @alternatives = alternatives.compact_blank
  end
end
