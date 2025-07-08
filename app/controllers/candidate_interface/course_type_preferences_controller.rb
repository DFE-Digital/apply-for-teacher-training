module CandidateInterface
  class CourseTypePreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :redirect_to_root_path_if_flag_is_inactive
    before_action :set_back_path # depends on training location?

    def new
      @course_type_preference_form = CourseTypePreferenceForm.new(
        {
          course_type: @preference.course_type,
          preference: @preference,
        },
      )
    end

    def create
      @course_type_preference_form = CourseTypePreferenceForm.new(
        course_type: course_type_params[:course_type],
        preference: @preference,
      )

      if @course_type_preference_form.valid?
        @course_type_preference_form.save!
        redirect_to candidate_interface_draft_preference_path(@preference)
      else
        render :new
      end
    end

  private

    def course_type_params
      params.fetch(:candidate_interface_course_type_preference_form, {}).permit(:course_type)
    end

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params.expect(:draft_preference_id))

      if @preference.blank?
        redirect_to candidate_interface_application_choices_path
      end
    end

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end

    def set_back_path
      @back_path = CourseTypePreferenceForm.new({ preference: @preference })
        .back_link(params[:return_to])
    end
  end
end
