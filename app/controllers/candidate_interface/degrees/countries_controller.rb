module CandidateInterface
  module Degrees
    class CountriesController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @form = Degrees::CountryForm.new(degree_store, degree_attrs)

        if params[:context] == 'new_degree'
          @form.uk_or_non_uk = nil
          @form.country = nil
          @form.clear_state!
        else
          @form.save_state!
        end
      end

      def update
        @form = Degrees::CountryForm.new(degree_store, country_params)

        if @form.valid?
          @form.save_state!
          next_step!
        else
          render 'new'
        end
      end

    private

      def country_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: %i[uk_or_non_uk country]))
      end
    end
  end
end
