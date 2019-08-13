class PersonalDetailsController < ApplicationController

  def create
    @user = Candidate.new user_params

    if @user.save
      sign_in @user # <-- This!
      redirect_to @user, flash: {notice: 'Welcome!'}
    else
      render :new
    end
  end


end
