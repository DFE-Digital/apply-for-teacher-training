class CandidateApplicationsController < ApplicationController
  def index
    @applications = CandidateApplication.all
    @actor = params[:actor]
  end

  def update
    application = CandidateApplication.find(params[:id])
    application.aasm.fire!(params[:application_event].to_sym, params[:actor])

    redirect_to tt_applications_path(actor: params[:actor])
  end
end
