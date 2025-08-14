module CandidateInterface
  module Degrees
    class EnicReasonsController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @wizard = Degrees::EnicReasonForm.new(degree_store, degree_attrs)
        @wizard.referer = request.referer
        @wizard.save_state!
      end

      def update
        @wizard = Degrees::EnicReasonForm.new(degree_store, enic_reason_params)

        if @wizard.valid?
          @wizard.save_state!
          next_step!
        else
          render 'new'
        end
      end

    private

      def enic_reason_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: :enic_reason))
      end
    end
  end
end
