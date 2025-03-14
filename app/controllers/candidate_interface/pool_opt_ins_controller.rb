module CandidateInterface
  class PoolOptInsController < CandidateInterfaceController
    def edit; end

    def update
      if current_candidate.update(pool_status: pool_status_params[:pool_status])
        redirect_to candidate_interface_location_preferences_path
      else
        render :edit
      end
    end

  private

    def pool_status_params
      params.expect(candidate: [:pool_status])
    end
  end
end
