module DataMigrations
  class IncorrectEqualityAndDiversityMigration
    TIMESTAMP = 20240225202828
    MANUAL_RUN = true
    OLD_HESA_VALUES = <<-SQL.freeze
      (equality_and_diversity->'hesa_sex' ?| array['1', '2', '3']) OR
      (equality_and_diversity->'hesa_ethnicity' ?| array['10','15','21','22','29','31','32','33','34','39','41','42','43','49','50','80','90','98']) OR
      (equality_and_diversity->'hesa_disabilities' ?| array['00','08']) OR
      (equality_and_diversity->'disabilities' ?| array['Learning difficulty', 'Social or communication impairment', 'Long-standing illness', 'Deaf', 'Blind'])
    SQL

    def change(limit: nil)
      return unless RecruitmentCycleTimetable.current_year == 2024

      records(limit:).find_each do |application_form|
        hesa_converter = HesaConverter.new(
          application_form:,
          recruitment_cycle_year: 2024,
        )

        equality_and_diversity = application_form.equality_and_diversity.merge(
          'hesa_sex' => hesa_converter.hesa_sex,
          'hesa_disabilities' => hesa_converter.hesa_disabilities,
          'disabilities' => hesa_converter.disabilities,
          'hesa_ethnicity' => hesa_converter.hesa_ethnicity,
        )

        application_form.update_columns(equality_and_diversity:)
        application_form.audits.create!(
          comment: 'E&D fixing incorrect and outdated HESA values',
          audited_changes: { equality_and_diversity: },
          action: :update,
          username: 'DataMigration',
        )
      end
    end

    # rubocop:disable Rails/Output
    def dry_run(limit: nil)
      puts "Number of records to change #{records.count}"

      records(limit:).find_each do |application_form|
        hesa_converter = HesaConverter.new(
          application_form:,
          recruitment_cycle_year: 2024,
        )

        puts '=' * 80
        puts "HESA sex: before: '#{application_form.equality_and_diversity['hesa_sex']}', after: '#{hesa_converter.hesa_sex}'"
        puts "HESA disabilities: before: '#{application_form.equality_and_diversity['hesa_disabilities']}', after: '#{hesa_converter.hesa_disabilities}'"
        puts "Disabilities: before: '#{application_form.equality_and_diversity['disabilities']}', after: '#{hesa_converter.disabilities}'"
        puts "HESA ethnicity: before: #{application_form.equality_and_diversity['ethnic_background']} - '#{application_form.equality_and_diversity['hesa_ethnicity']}', after: '#{hesa_converter.hesa_ethnicity}'"
        puts '=' * 80
      end
    end
    # rubocop:enable Rails/Output

    def records(limit: nil)
      scope = ApplicationForm.where.not(equality_and_diversity: nil)
        .where(recruitment_cycle_year: 2024)
        .where(OLD_HESA_VALUES)
      scope = scope.order(created_at: :asc).limit(limit) if limit.present?
      scope
    end
  end
end
