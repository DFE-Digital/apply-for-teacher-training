module ResultFilters
  class FundingController < ApplicationController
    include FilterParameters

    before_action :build_results_filter_query_parameters

    def new; end

    def create
      redirect_to results_path(filter_params)
    end

  private

    def build_results_filter_query_parameters
      @results_filter_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
        .query_parameters_with_defaults
    end
  end
end
