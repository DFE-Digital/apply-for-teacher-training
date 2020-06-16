module CandidateInterface
  module Degrees
    class TypeController < CandidateInterfaceController
      def new
        @degree_type_form = DegreeTypeForm.new
        degree_already_added? ? render('add_another') : render('new')
      end

      def create
        @degree_type_form = DegreeTypeForm.new(create_params)
        if @degree_type_form.save
          redirect_to candidate_interface_degree_subject_path(
            @degree_type_form.degree,
          )
        else
          render :new
        end
      end

    private

      def degree_type_params
        params
          .require(:candidate_interface_degree_type_form)
          .permit(:type_description)
      end

      def create_params
        degree_type_params.merge(application_form: current_application)
      end

      def degree_already_added?
        current_application.application_qualifications.degree.present?
      end

      def degree
        @degree ||= ApplicationQualification.find(params[:id])
      end
    end
  end
end
