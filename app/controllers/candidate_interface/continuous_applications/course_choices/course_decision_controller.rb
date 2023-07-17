module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class CourseDecisionController < ::CandidateInterface::ContinuousApplicationsController
        def ask
          #@choice_form = CandidateInterface::CourseChosenForm.new
        end

        def decide
      #    @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)
      #    set_backlink
      #    render :ask and return unless @choice_form.valid?

      #    if @choice_form.chosen_a_course?
      #      redirect_to candidate_interface_course_choices_provider_path
      #    else
      #      redirect_to candidate_interface_go_to_find_path
      #    end
        end

      private

        def application_choice_params
          params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
        end
      end
    end
  end
end
