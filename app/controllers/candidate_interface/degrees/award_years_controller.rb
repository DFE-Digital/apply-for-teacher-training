module CandidateInterface
  module Degrees
    class AwardYearsController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id, id: params[:id] }.compact
        @form = Degrees::AwardYearForm.new(degree_store, degree_attrs)
        @form.save_state!
      end

      def update
        @form = Degrees::AwardYearForm.new(degree_store, award_year_params)

        if @form.valid?
          @form.save_state!
          next_step!
        else
          render :new
        end
      end

    private

      def award_year_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace(params.expect(candidate_interface_degree_form: :award_year))
      end
    end
  end
end
