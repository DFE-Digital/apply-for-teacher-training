module CandidateInterface
  module Degrees
    class TypeController < BaseController
      before_action :set_degree_type_names, only: %i[edit update]

      def new
        @degree_type_form = current_degree ? DegreeTypeForm.new(degree: current_degree).assign_form_values : DegreeTypeForm.new

        conditionally_render_new_degree_type_form
      end

      def create
        degree_type_params = current_degree ? update_params : create_params
        @degree_type_form = DegreeTypeForm.new(degree_type_params)

        if (current_degree && @degree_type_form.update) || @degree_type_form.save
          redirect_to candidate_interface_degree_subject_path(
            @degree_type_form.degree,
          )
        else
          track_validation_error(@degree_type_form)
          conditionally_render_new_degree_type_form
        end
      end

      def edit
        @degree_type_form = DegreeTypeForm.new(degree: current_degree).assign_form_values
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)
      end

      def update
        @degree_type_form = DegreeTypeForm.new(update_params)
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)

        if @degree_type_form.update
          redirect_to @return_to[:back_path]
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
        strip_whitespace params
          .require(:candidate_interface_degree_type_form)
          .permit(:uk_degree, :type_description, :international_type_description)
      end

      def create_params
        degree_type_params.merge(application_form: current_application)
      end

      def update_params
        degree_type_params.merge(degree: current_degree)
      end

      def degree_already_added?
        current_application.application_qualifications.degree.present?
      end
    end
  end
end
