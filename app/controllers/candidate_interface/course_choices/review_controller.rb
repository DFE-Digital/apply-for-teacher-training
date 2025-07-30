module CandidateInterface
  module CourseChoices
    class ReviewController < CandidateInterface::CourseChoices::BaseController
      skip_before_action CarryOverFilter
      skip_before_action :redirect_to_your_applications_if_cycle_is_over

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])

        @invite = Pool::Invite.find_by(
          application_form_id: @application_choice.application_form_id,
          course_id: @application_choice.current_course_option.course_id,
        )

        @back_link = if params['return_to'] == 'invites'
                       candidate_interface_invites_path
                     elsif params['return_to'] == 'edit_invite'
                       edit_candidate_interface_invite_path(@invite)
                     else
                       candidate_interface_application_choices_path
                     end
      end
    end
  end
end
