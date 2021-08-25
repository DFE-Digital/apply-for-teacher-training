module CandidateInterface
  module CourseChoices
    class UCASController < BaseController
      def no_courses
        @provider = Provider.find(params[:provider_id])
      end

      def with_course
        @provider = Provider.find(params[:provider_id])
        @course = Course.find(params[:course_id])

        @return_to_path = if params[:return_to].nil?
                            candidate_interface_course_choices_course_path(@provider.id)
                          else
                            candidate_interface_edit_course_choices_course_path(
                              course_choice_id: params[:previous_course_choice_id],
                              return_to: params[:return_to],
                            )
                          end
      end
    end
  end
end
