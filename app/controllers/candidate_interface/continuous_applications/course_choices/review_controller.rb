module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ReviewController < BaseController
        before_action :set_back_link

        def show
          @application_choice = current_application.application_choices.find(params[:application_choice_id])
          @submit_application_form = CandidateInterface::ContinuousApplications::SubmitApplicationForm.new(
            application_choice: @application_choice,
          )
        end

      private

        def set_back_link
          @return_to = if referrer_blank?
                         [candidate_interface_continuous_applications_choices_path]
                       elsif referrer_step?
                         [request.referer]
                       elsif referrer_view?
                         [request.referer, 'Back to your applications']
                       end
        end

        # User arrives from the View Application link
        def referrer_view?
          request.referer.match?(Regexp.compile('/candidate/application/choices\Z'))
        end

        # User arrives on the review page from the last wizard step
        def referrer_step?
          request.referer.match?(Regexp.compile('/candidate/application/continuous-applications'))
        end

        # User does not visit the page from another page, probably bookmarked
        def referrer_blank?
          request.referer.blank?
        end
      end
    end
  end
end
