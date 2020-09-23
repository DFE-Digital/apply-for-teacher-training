module FindSync
  class CourseVacancyStatus
    def initialize(find_status_description, study_mode)
      @find_status_description = find_status_description
      @study_mode = study_mode
    end

    def derive
      case @find_status_description
      when 'no_vacancies'
        :no_vacancies
      when 'both_full_time_and_part_time_vacancies'
        :vacancies
      when 'full_time_vacancies'
        @study_mode == 'full_time' ? :vacancies : :no_vacancies
      when 'part_time_vacancies'
        @study_mode == 'part_time' ? :vacancies : :no_vacancies
      else
        raise InvalidFindStatusDescriptionError, @find_status_description
      end
    end

    class InvalidFindStatusDescriptionError < StandardError; end
  end
end
