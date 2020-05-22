module CandidateInterface
  module CourseChoices
    class SiteSelectionController < BaseController
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
end
