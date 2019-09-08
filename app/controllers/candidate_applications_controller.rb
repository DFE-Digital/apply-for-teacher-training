class CandidateApplicationsController < ApplicationController
  def create
    CandidateApplication.create!

    redirect_to tt_applications_path(actor: 'candidate')
  end

  def index
    @applications = CandidateApplication.all.order('created_at desc')
    @actor = params[:actor]
  end

  def update
    application = CandidateApplication.find(params[:id])
    application.aasm.fire!(params[:application_event].to_sym, params[:actor])

    redirect_to tt_applications_path(actor: params[:actor])
  end

  def destroy
    CandidateApplication.delete_all

    redirect_to tt_applications_path(actor: params[:actor])
  end
end
