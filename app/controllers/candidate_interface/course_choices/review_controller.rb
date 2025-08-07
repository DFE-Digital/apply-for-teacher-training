module CandidateInterface
  module CourseChoices
    class ReviewController < CandidateInterface::CourseChoices::BaseController
      skip_before_action CarryOverFilter
      skip_before_action :redirect_to_your_applications_if_cycle_is_over

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])

        if params['return_to'] == 'invite'
          invite = application_choice.published_invites.last
        end

        @back_link = if invite.present?
                       edit_candidate_interface_invite_path(invite)
                     elsif params['return_to'] == 'invites'
                       candidate_interface_invites_path
                     else
                       candidate_interface_application_choices_path
                     end
      end
    end
  end
end
