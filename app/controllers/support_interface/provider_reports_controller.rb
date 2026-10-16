module SupportInterface
  class ProviderReportsController < SupportInterfaceController
    before_action :set_provider
    def index
      @previous_timetable = RecruitmentCycleTimetable.previous_timetable
    end

    def set_provider
      @provider ||= Provider.find(params.permit(:provider_id)[:provider_id])
    end
  end
end
