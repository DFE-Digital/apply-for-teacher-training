module CandidateInterface
  module Degrees
    class LevelsController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @wizard = Degrees::LevelForm.new(degree_store, degree_attrs)
        @wizard.referer = request.referer
        @wizard.save_state!
      end

      def update
        @wizard = Degrees::LevelForm.new(degree_store, level_params)
        if @wizard.valid?
          @wizard.save_state!
          next_step!
        else
          render 'new'
        end
      end

    private

      def level_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: %i[degree_level equivalent_level]))
      end
    end
  end
end
