module DataMigrations
  class FixQualificationAwardYear
    TIMESTAMP = 20211014091914
    MANUAL_RUN = false

    def change
      ApplicationQualification
        .includes(:application_form)
        .where(application_form: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .where(level: %i[gcse other])
        .where('length(award_year) > 4')
        .find_each do |qualification|
        year_to_update_to = nil

        if award_year_matches_pattern_one?(qualification)
          year_to_update_to = qualification.award_year.split.last
        end

        if award_year_matches_pattern_two?(qualification)
          year_to_update_to = qualification.award_year.split('/').last
        end

        if award_year_matches_pattern_three?(qualification)
          first_year, last_year = qualification.award_year.split('/')
          year_to_update_to = first_year[0..1] + last_year
        end

        if year_to_update_to
          qualification.update(award_year: year_to_update_to, audit_comment: 'Fixing award year formatting')
        end
      end
    end

  private

    def award_year_matches_pattern_one?(qualification)
      /\A\d{4} (-|and|\/) \d{4}\z/.match?(qualification.award_year)
    end

    def award_year_matches_pattern_two?(qualification)
      /\A\d{4}\/\d{4}\z/.match?(qualification.award_year)
    end

    def award_year_matches_pattern_three?(qualification)
      /\A\d{4}\/\d{2}\z/.match?(qualification.award_year)
    end
  end
end
