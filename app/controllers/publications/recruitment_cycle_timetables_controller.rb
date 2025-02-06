module Publications
  class RecruitmentCycleTimetablesController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: { data: Publications::RecruitmentCycleTimetablesPresenter.new(timetables).call }
        end

        format.html do
          @timetables = timetables
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          if timetable.present?
            render json: { data: Publications::RecruitmentCycleTimetablesPresenter.new(timetable).call }
          else
            years = RecruitmentCycleTimetable.all.pluck(:recruitment_cycle_year)
            render json: { errors: [{
              error: 'NotFound',
              message: "Recruitment cycle year should be between #{years.min} and #{years.max}",
            }] }, status: :not_found
          end
        end

        format.html do
          if timetable.present?
            @timetable = timetable
          else
            render 'errors/not_found', status: :not_found
          end
        end
      end
    end

  private

    def timetables
      RecruitmentCycleTimetable.all.order(recruitment_cycle_year: :desc)
    end

    def timetable
      if recruitment_cycle_year_param == 'current'
        RecruitmentCycleTimetable.current_timetable
      else
        timetables.find_by(
          recruitment_cycle_year: recruitment_cycle_year_param,
        )
      end
    end

    def recruitment_cycle_year_param
      params[:recruitment_cycle_year]
    end
  end
end
