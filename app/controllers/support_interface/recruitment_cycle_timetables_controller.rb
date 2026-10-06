module SupportInterface
  class RecruitmentCycleTimetablesController < SupportInterfaceController
    before_action :edit_correct_timetable, only: %i[edit update]
    def index
      @timetable_presenter = SupportInterface::RecruitmentCycleTimetablePresenter.new(current_timetable)
      @timetable_to_review = RecruitmentCycleTimetable.find_by(
        recruitment_cycle_year: @current_timetable.recruitment_cycle_year + 3,
      )
    end

    def show
      @timetable = timetable
      if params[:publish]
        flash[:success] = I18n.t(
          'support_interface.recruitment_cycle_timetables.update.publish_message',
          cycle_range: timetable.cycle_range_name,
        )
        redirect_to support_interface_recruitment_cycle_timetables_path
      end
    end

    def edit
      @timetable = timetable
      @cycle_switcher_form = SupportInterface::CycleSwitcherFormBuilder.new.build(timetable:)
    end

    def update
      @cycle_switcher_form = SupportInterface::CycleSwitcherFormBuilder.new.build(
        recruitment_cycle_timetable_form_params, timetable:
      )

      if @cycle_switcher_form.persist
        message = if timetable.three_timetables_from_now?
                    I18n.t(
                      'support_interface.recruitment_cycle_timetables.update.publish_message',
                      cycle_range: timetable.cycle_range_name,
                    )
                  else
                    I18n.t('support_interface.recruitment_cycle_timetables.update.success_message')
                  end
        flash[:success] = message

        redirect_to support_interface_recruitment_cycle_timetables_path
      else
        @timetable = timetable
        render :edit
      end
    end

    def reset
      ProductionRecruitmentCycleTimetablesAPI::SyncTimetablesWithProduction.new.call
      flash[:success] = I18n.t('support_interface.recruitment_cycle_timetables.reset.success_message')
      redirect_to support_interface_recruitment_cycle_timetables_path
    end

  private

    def edit_correct_timetable
      return unless HostingEnvironment.production?

      unless timetable.three_timetables_from_now? && Time.zone.now.month == 7
        redirect_to support_interface_path
      end
    end

    def recruitment_cycle_year_params
      params.expect(:recruitment_cycle_year)
    end

    def timetable
      RecruitmentCycleTimetable.find_by!(recruitment_cycle_year: recruitment_cycle_year_params)
    end

    def recruitment_cycle_timetable_form_params
      params.expect(
        support_interface_cycle_switcher_form: %i[
          find_opens_at
          apply_opens_at
          apply_deadline_at
          reject_by_default_at
          decline_by_default_at
          find_closes_at
          winter_reject_by_default_at
          winter_decline_by_default_at
        ],
      )
    end
  end
end
