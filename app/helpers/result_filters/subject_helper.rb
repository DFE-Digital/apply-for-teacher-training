module ResultFilters
  module SubjectHelper
    include FilterParameters

    def subject_is_selected?(id:)
      if params["subjects"] && params["subjects"].length
        id.in?(params["subjects"])
      else
        false
      end
    end

    def subject_area_is_selected?(subject_area:)
      return false if params["subjects"].nil?

      (params["subjects"] & subject_area.subjects.map(&:id)).any?
    end

    def no_subject_selected_error?
      return false if flash[:error].nil?

      flash[:error].include?(I18n.t("subject_filter.errors.no_option"))
    end
  end
end
