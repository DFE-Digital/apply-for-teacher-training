module CandidateInterface
  module CourseChoices
    class CourseSelectionController < BaseController
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

    private

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

          if @course_choices.count.between?(1, 2) && !current_application.apply_again?
            redirect_to candidate_interface_course_choices_add_another_course_path
          else
            redirect_to candidate_interface_course_choices_index_path
          end

        else
          flash[:warning] = @pick_site.errors.full_messages.first
          redirect_to candidate_interface_application_form_path
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
    end
  end
end
