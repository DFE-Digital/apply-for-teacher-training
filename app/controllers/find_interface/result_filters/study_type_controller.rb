module ResultFilters
  class StudyTypeController < ApplicationController
    include FilterParameters

    before_action :build_results_filter_query_parameters

    def new; end

    def create
      if [filter_params[:fulltime], filter_params[:parttime]].any? { |param| param.downcase == "true" }
        redirect_to results_path(filter_params)
      else
        flash[:error] = "You must make at least one selection"
        redirect_to studytype_path(filter_params)
      end
    end

  private

    def build_results_filter_query_parameters
      @results_filter_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
        .query_parameters_with_defaults
    end
  end
end
