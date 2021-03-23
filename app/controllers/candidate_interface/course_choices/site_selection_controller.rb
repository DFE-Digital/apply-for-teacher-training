module CandidateInterface
  module CourseChoices
    class SiteSelectionController < BaseController
      def new
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

      def create
        course_id = params.fetch(:course_id)
        course_option_id = params.dig(:candidate_interface_pick_site_form, :course_option_id)

        @pick_site = PickSiteForm.new(
          application_form: current_application,
          provider_id: params.fetch(:provider_id),
          course_id: course_id,
          study_mode: params.fetch(:study_mode),
          course_option_id: course_option_id,
        )

        render :new and return unless @pick_site.valid?

        candidate_is_updating_a_choice = params[:course_choice_id]
        if candidate_is_updating_a_choice
          PickCourseOption
            .new(course_id, course_option_id, current_application, params.fetch(:provider_id), self, id_of_course_choice_to_replace: params[:course_choice_id])
            .call
        elsif candidate_has_already_chosen_this_course
          redirect_to candidate_interface_course_choices_index_path
        else
          PickCourseOption
            .new(course_id, course_option_id, current_application, params.fetch(:provider_id), self)
            .call
        end
      end

    private

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
