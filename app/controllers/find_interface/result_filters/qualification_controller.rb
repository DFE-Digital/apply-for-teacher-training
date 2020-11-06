module ResultFilters
  class QualificationController < ApplicationController
    include FilterParameters

    before_action :create_view, :build_results_filter_query_parameters

    def new; end

    def create
      if @view.qualification_selected?
        redirect_to results_path(filter_params)
      else
        flash[:error] = "Please choose at least one qualification"
        redirect_to qualification_path(filter_params)
      end
    end

  private

    def build_results_filter_query_parameters
      @results_filter_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
        .query_parameters_with_defaults
    end

    def create_view
      @view = ResultFilters::QualificationView.new(params: params)
    end
  end
end
