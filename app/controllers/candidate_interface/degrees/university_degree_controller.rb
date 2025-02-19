module CandidateInterface
  module Degrees
    class UniversityDegreeController < BaseController
      def new
        @university_degree_form = UniversityDegreeForm.new(
          current_application:,
          university_degree_status: current_application.university_degree,
        )
      end

      def update
        @university_degree_form = UniversityDegreeForm.new(form_params.merge(current_application:))

        return render :new unless @university_degree_form.valid?

        if @university_degree_form.degree?
          current_application.update!(university_degree: true)
          redirect_to candidate_interface_degree_country_path
        else
          current_application.update!(university_degree: false, degrees_completed: true)
          redirect_to candidate_interface_details_path
        end
      end

    private

      def form_params
        params.fetch(:candidate_interface_university_degree_form, {}).permit(:university_degree_status)
      end
    end
  end
end
