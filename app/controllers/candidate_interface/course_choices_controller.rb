module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def index
      @course_choices = current_candidate.current_application.application_choices
      if @course_choices.count < 1
        render :index
      else
        redirect_to candidate_interface_course_choices_review_path
      end
    end

    def have_you_chosen
      @choice_form = CandidateInterface::CourseChosenForm.new
    end

    def make_choice
      @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)
      render :have_you_chosen and return unless @choice_form.valid?

      if @choice_form.chosen_a_course?
        redirect_to candidate_interface_course_choices_provider_path
      else
        redirect_to candidate_interface_go_to_find_path
      end
    end

    def go_to_find; end

    def options_for_provider
      @pick_provider = PickProviderForm.new
    end

    def pick_provider
      @pick_provider = PickProviderForm.new(
        provider_id: params.dig(:candidate_interface_pick_provider_form, :provider_id),
      )
      render :options_for_provider and return unless @pick_provider.valid?

      if @pick_provider.courses_available?
        redirect_to candidate_interface_course_choices_course_path(@pick_provider.provider_id)
      else
        redirect_to candidate_interface_course_choices_ucas_no_courses_path(@pick_provider.provider_id)
      end
    end

    def ucas_no_courses
      @provider = Provider.find_by!(id: params[:provider_id])
    end

    def ucas_with_course
      @provider = Provider.find_by!(id: params[:provider_id])
      @course = Course.find_by!(id: params[:course_id])
    end

    def options_for_course
      if params[:course_choice_id]
        @course_choice_id = params[:course_choice_id]
        current_application_choice = current_application.application_choices.find(@course_choice_id)

        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          application_form: current_application,
          course_id: current_application_choice.course.id,
        )
      else
        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          application_form: current_application,
        )
      end
    end

    def pick_course
      course_id = params.dig(:candidate_interface_pick_course_form, :course_id)
      @pick_course = PickCourseForm.new(
        provider_id: params.fetch(:provider_id),
        course_id: course_id,
        application_form: current_application,
      )
      render :options_for_course and return unless @pick_course.valid?

      if !@pick_course.open_on_apply?
        redirect_to candidate_interface_course_choices_ucas_with_course_path(@pick_course.provider_id, @pick_course.course_id)
      elsif @pick_course.full?
        redirect_to candidate_interface_course_choices_full_path(
          @pick_course.provider_id,
          @pick_course.course_id,
        )
      elsif @pick_course.both_study_modes_available?
        redirect_to candidate_interface_course_choices_study_mode_path(
          @pick_course.provider_id,
          @pick_course.course_id,
          course_choice_id: params[:course_choice_id],
        )
      elsif @pick_course.single_site?
        course_option = CourseOption.where(course_id: @pick_course.course.id).first
        if params[:course_choice_id]
          pick_new_site_for_course(course_id, course_option.id)
        else
          pick_site_for_course(course_id, course_option.id)
        end
      else
        redirect_to candidate_interface_course_choices_site_path(
          @pick_course.provider_id,
          @pick_course.course_id,
          @pick_course.study_mode,
          course_choice_id: params[:course_choice_id],
        )
      end
    end

    def full
      @course = Course.find(params[:course_id])
    end

    def options_for_study_mode
      if params[:course_choice_id]
        @course_choice_id = params[:course_choice_id]
        current_application_choice = current_application.application_choices.find(@course_choice_id)

        @pick_study_mode = PickStudyModeForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
          study_mode: current_application_choice.offered_option.study_mode,
        )
      else
        @pick_study_mode = PickStudyModeForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
        )
      end
    end

    def pick_study_mode
      @pick_study_mode = PickStudyModeForm.new(
        provider_id: params.fetch(:provider_id),
        course_id: params.fetch(:course_id),
        study_mode: params.dig(
          :candidate_interface_pick_study_mode_form,
          :study_mode,
        ),
      )
      render :options_for_study_mode and return unless @pick_study_mode.valid?

      if @pick_study_mode.single_site_course?
        if params[:course_choice_id]
          pick_new_site_for_course(
            @pick_study_mode.course_id,
            @pick_study_mode.first_site_id,
          )
        else
          pick_site_for_course(
            @pick_study_mode.course_id,
            @pick_study_mode.first_site_id,
          )
        end
      else
        redirect_to candidate_interface_course_choices_site_path(
          @pick_study_mode.provider_id,
          @pick_study_mode.course_id,
          @pick_study_mode.study_mode,
          course_choice_id: params[:course_choice_id],
        )
      end
    end

    def options_for_site
      candidate_is_updating_a_choice = params[:course_choice_id]
      if candidate_is_updating_a_choice
        @course_choice_id = params[:course_choice_id]
        current_application_choice = current_application.application_choices.find(@course_choice_id)

        @pick_site = PickSiteForm.new(
          application_form: current_application,
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
          study_mode: params.fetch(:study_mode),
          course_option_id: current_application_choice.course_option_id.to_s,
        )
      elsif candidate_has_already_chosen_this_course
        redirect_to candidate_interface_course_choices_index_path
      else
        @pick_site = PickSiteForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
          study_mode: params.fetch(:study_mode),
        )
      end
    end

    def pick_site
      course_id = params.fetch(:course_id)
      course_option_id = params.dig(:candidate_interface_pick_site_form, :course_option_id)

      candidate_is_updating_a_choice = params[:course_choice_id]
      if candidate_is_updating_a_choice
        pick_new_site_for_course(course_id, course_option_id)
      elsif candidate_has_already_chosen_this_course
        redirect_to candidate_interface_course_choices_index_path
      else
        pick_site_for_course(course_id, course_option_id)
      end
    end

    def review
      @application_form = current_application
      @course_choices = current_candidate.current_application.application_choices
    end

    def confirm_destroy
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
    end

    def destroy
      current_application
        .application_choices
        .find(current_course_choice_id)
        .destroy!

      current_application.update!(course_choices_completed: false)

      redirect_to candidate_interface_course_choices_index_path
    end

    def add_another_course
      @additional_courses_allowed = 3 - current_candidate.current_application.application_choices.count
      @add_another_course = AddAnotherCourseForm.new
    end

    def add_another_course_selection
      @additional_courses_allowed = 3 - current_candidate.current_application.application_choices.count
      @add_another_course = AddAnotherCourseForm.new(add_another_course_params)
      return render :add_another_course unless @add_another_course.valid?

      if @add_another_course.add_another_course?
        redirect_to candidate_interface_course_choices_choose_path
      else
        redirect_to candidate_interface_course_choices_index_path
      end
    end

    def complete
      @application_form = current_application

      render :index if @application_form.application_choices.count.zero?

      if @application_form.submitted?
        @application_form.application_choices.filter(&:unsubmitted?).each { |choice| SubmitApplicationChoice.new(choice).call }
      end

      if @application_form.update(application_form_params)
        redirect_to candidate_interface_application_form_path
      else
        @course_choices = current_candidate.current_application.application_choices
        track_validation_error(@application_form)

        render :review
      end
    end

  private

    def current_course_choice_id
      params.permit(:id)[:id]
    end

    def application_form_params
      params.require(:application_form).permit(:course_choices_completed)
    end

    def application_choice_params
      params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
    end

    def add_another_course_params
      params.fetch(:candidate_interface_add_another_course_form, {}).permit(:add_another_course)
    end

    def pick_site_for_course(course_id, course_option_id)
      @pick_site = PickSiteForm.new(
        application_form: current_application,
        provider_id: params.fetch(:provider_id),
        course_id: course_id,
        course_option_id: course_option_id,
      )

      if @pick_site.save
        current_application.update!(course_choices_completed: false)
        @course_choices = current_candidate.current_application.application_choices
        flash[:success] = "You’ve added #{@course_choices.last.course.name_and_code} to your application"

        if @course_choices.count.between?(1, 2)
          redirect_to candidate_interface_course_choices_add_another_course_path
        else
          redirect_to candidate_interface_course_choices_index_path
        end

      else
        render :options_for_site
      end
    end

    def pick_new_site_for_course(course_id, course_option_id)
      @course_choice_id = params[:course_choice_id]
      application_choice = current_application.application_choices.find(params[:course_choice_id])

      @pick_site = PickSiteForm.new(
        application_form: current_application,
        provider_id: params.fetch(:provider_id),
        course_id: course_id,
        course_option_id: course_option_id,
      )

      if @pick_site.update(application_choice)
        redirect_to candidate_interface_course_choices_index_path
      else
        render :options_for_site
      end
    end

    def candidate_has_already_chosen_this_course
      provider = Provider.find(params.fetch(:provider_id))
      course = provider.courses.find(params.fetch(:course_id))

      course_already_chosen = current_application
        .application_choices
        .includes([:course])
        .any? { |application_choice| application_choice.course == course }

      if course_already_chosen
        flash[:warning] = I18n.t!('errors.application_choices.already_added', course_name_and_code: course.name_and_code)
        true
      else
        false
      end
    end
  end
end
