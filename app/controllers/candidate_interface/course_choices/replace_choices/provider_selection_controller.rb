module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class ProviderSelectionController < BaseController
        def new
          @course_choice = current_application.application_choices.find(params[:id])
          @pick_provider = PickProviderForm.new
        end

        def create
          @course_choice = current_application.application_choices.find(params[:id])
          @pick_provider = PickProviderForm.new(
            provider_id: params.dig(:candidate_interface_pick_provider_form, :provider_id),
          )
          render :new and return unless @pick_provider.valid?

          if @pick_provider.courses_available?
            redirect_to candidate_interface_replace_course_choice_course_path(@course_choice.id, @pick_provider.provider_id)
          else
            redirect_to candidate_interface_replace_course_choice_ucas_no_courses_path(@course_choice.id, @pick_provider.provider_id)
          end
        end
      end
    end
  end
end
