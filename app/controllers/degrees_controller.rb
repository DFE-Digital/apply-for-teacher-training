class DegreesController < ApplicationController
  def new
    @degree = Degree.new
  end

  def create
    @degree = Degree.new(degree_params)

    if @degree.save
      redirect_to new_qualification_path
    else
      render :new
    end
  end

  def edit
    @degree = Degree.find(params[:id])
  end

  def update
    @degree = Degree.find(params[:id])

    if @degree.update(degree_params)
      redirect_to check_your_answers_path
    else
      render :edit
    end
  end

private

  def degree_params
    params.require(:degree).permit(:type_of_degree, :subject, :institution, :class_of_degree, :year)
  end
end
