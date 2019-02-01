class ProfileController < ApplicationController
  before_action :set_candidate

  def show
  end

  def edit
  end

  def update
    if @candidate.update(candidate_params)
      redirect_to profile_path, notice: 'Profile updated'
    else
      render :edit
    end
  end

  private

  def candidate_params
    params.require(:candidate).permit(
      :title,
      :first_name,
      :surname,
      :date_of_birth,
      :gender,
      :address_1,
      :address_2,
      :town,
      :county,
      :post_code,
      :country,
      :mobile,
      :telephone
    )
  end

  def set_candidate
    @candidate = current_candidate
  end
end
