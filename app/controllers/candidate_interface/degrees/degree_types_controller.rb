module CandidateInterface
  module Degrees
    class DegreeTypesController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @wizard = Degrees::TypeForm.new(degree_store, degree_attrs)
        redirect_if_irrelevant_step

        @wizard.referer = request.referer
        @wizard.save_state!
      end

      def update
        @wizard = Degrees::TypeForm.new(degree_store, type_params)
        redirect_if_irrelevant_step

        if @wizard.valid?
          @wizard.save_state!
          next_step!
        else
          render 'new'
        end
      end

    private

      def redirect_if_irrelevant_step
        return if @wizard.degree_has_type?

        next_step!
        nil
      end

      def type_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: %i[type other_type other_type_raw]))
      end
    end
  end
end
