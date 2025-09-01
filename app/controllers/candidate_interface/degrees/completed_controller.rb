module CandidateInterface
  module Degrees
    class CompletedController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @form = Degrees::CompletedForm.new(degree_store, degree_attrs)
        @form.save_state!
      end

      def update
        @form = Degrees::CompletedForm.new(degree_store, completed_params)

        if @form.valid?
          @form.save_state!
          next_step!
        else
          render :new
        end
      end

    private

      def completed_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: :completed))
      end
    end
  end
end
