class QualificationsController < ApplicationController
  def new
    @qualification = Qualification.new
  end

  def create
    @qualification = Qualification.new(qualification_params)

    if @qualification.save
      redirect_to check_your_answers_path
    else
      render :new
    end
  end

  def edit
    @qualification = Qualification.find(params[:id])
  end

  def update
    @qualification = Qualification.find(params[:id])

    if @qualification.update(qualification_params)
      redirect_to check_your_answers_path
    else
      render :edit
    end
  end

private

  def qualification_params
    params.require(:qualification).permit(:type_of_qualification, :subject, :institution, :grade, :year)
  end
end
