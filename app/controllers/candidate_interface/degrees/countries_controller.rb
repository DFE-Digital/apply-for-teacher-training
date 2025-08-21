module CandidateInterface
  module Degrees
    class CountriesController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @wizard = Degrees::CountryForm.new(degree_store, degree_attrs)

        if params[:context] == 'new_degree'
          @wizard.uk_or_non_uk = nil
          @wizard.country = nil
          @wizard.clear_state!
        else
          @wizard.referer = request.referer
          @wizard.save_state!
        end
      end

      def update
        @wizard = Degrees::CountryForm.new(degree_store, country_params)

        if @wizard.valid?
          @wizard.save_state!
          next_step!
        else
          render 'new'
        end
      end

    private

      def country_params
        return {} if params[:candidate_interface_degree_form].blank?

        set_country_for_uk

        strip_whitespace(params.expect(candidate_interface_degree_form: %i[uk_or_non_uk country]))
      end

      def set_country_for_uk
        if params.dig(:candidate_interface_degree_form, :uk_or_non_uk) == 'uk'
          params[:candidate_interface_degree_form][:country] = 'GB'
        end
      end
    end
  end
end
