module CandidateInterface
  class TrainingLocationsController < CandidateInterfaceController
    before_action :set_preference
    before_action :set_back_path
    before_action :set_submit_path, only: :new

    def new
      if @preference.published?
        @preference = @preference.create_draft_dup
      end

      @training_locations_form = TrainingLocationsForm.build_from_preference(@preference)
    end

    def create
      @training_locations_form = TrainingLocationsForm.new(
        { training_locations: form_params[:training_locations] }.merge(preference: @preference),
      )

      if @training_locations_form.valid?
        @training_locations_form.save!
        redirect_to @training_locations_form.next_step_path(return_to: params[:return_to])
      else
        set_submit_path
        render :new
      end
    end

    def form_params
      params.fetch(:candidate_interface_training_locations_form, {}).permit(:training_locations)
    end

  private

    def set_preference
      @preference = current_application.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_application_choices_path
      end
    end

    def set_back_path
      @back_path = if return_to_review?
                     candidate_interface_draft_preference_path(@preference)
                   else
                     edit_candidate_interface_pool_opt_in_path(@preference)
                   end
    end

    def set_submit_path
      @submit_path = if return_to_review?
                       candidate_interface_draft_preference_training_locations_path(
                         @preference,
                         return_to: 'review',
                       )
                     else
                       candidate_interface_draft_preference_training_locations_path(@preference)
                     end
    end

    def return_to_review?
      params[:return_to] == 'review'
    end
  end
end
