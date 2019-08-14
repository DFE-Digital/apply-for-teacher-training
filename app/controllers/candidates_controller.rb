class CandidatesController < ApplicationController

  def summary
    require_candidate!
  end
end
