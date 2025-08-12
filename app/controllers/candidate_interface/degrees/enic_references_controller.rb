module CandidateInterface
  module Degrees
    class EnicReferencesController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @form = Degrees::EnicReferenceForm.new(degree_store, degree_attrs)
        @form.save_state!
      end

      def update
        @form = Degrees::EnicReferenceForm.new(degree_store, enic_reference_params)

        if @form.valid?
          @form.save_state!
          next_step!
        else
          render :new
        end
      end

    private

      def enic_reference_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: %i[enic_reference comparable_uk_degree]))
      end
    end
  end
end
