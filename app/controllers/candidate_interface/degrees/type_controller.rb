module CandidateInterface
  module Degrees
    class TypeController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted
      before_action :set_degree_type_names, only: %i[edit update]

      def new
        @degree_type_form = DegreeTypeForm.new
        conditionally_render_new_degree_type_form
      end

      def create
        @degree_type_form = DegreeTypeForm.new(create_params)
        if @degree_type_form.save
          redirect_to candidate_interface_degree_subject_path(
            @degree_type_form.degree,
          )
        else
          conditionally_render_new_degree_type_form
        end
      end

      def edit
        @degree_type_form = DegreeTypeForm.new(degree: degree).fill_form_values
      end

      def update
        @degree_type_form = DegreeTypeForm.new(update_params)
        if @degree_type_form.update
          current_application.update!(degrees_completed: false)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_type_form)
          render :edit
        end
      end

    private

      def set_degree_type_names
        @degree_types = Hesa::DegreeType.abbreviations_and_names
      end

      def conditionally_render_new_degree_type_form
        if degree_already_added?
          @degree_types = Hesa::DegreeType.abbreviations_and_names
          render :add_another
        else
          @degree_types = Hesa::DegreeType.abbreviations_and_names(level: :undergraduate)
          render :new
        end
      end

      def degree_type_params
        params
          .require(:candidate_interface_degree_type_form)
          .permit(:type_description)
      end

      def create_params
        degree_type_params.merge(application_form: current_application)
      end

      def update_params
        degree_type_params.merge(degree: degree)
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
