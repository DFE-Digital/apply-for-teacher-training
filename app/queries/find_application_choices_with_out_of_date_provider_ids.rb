class FindApplicationChoicesWithOutOfDateProviderIds
  def self.call
    with_course_joins = ApplicationChoice
                          .joins('INNER JOIN course_options AS current_course_option ON current_course_option_id = current_course_option.id')
                          .joins('INNER JOIN course_options AS course_option ON course_option_id = course_option.id')
                          .joins('INNER JOIN courses AS current_course ON current_course_option.course_id = current_course.id')
                          .joins('INNER JOIN courses AS course ON course_option.course_id = course.id')

    # SQL equivalent for .compact.uniq
    get_expected_provider_ids_sql = <<~GET_EXPECTED_PROVIDER_IDS_SQL.squish
      application_choices.id,
      ARRAY(
        SELECT DISTINCT i FROM unnest(
          ARRAY[
            course.provider_id,
            course.accredited_provider_id,
            current_course.provider_id,
            current_course.accredited_provider_id
          ]
        ) AS a(i) WHERE i IS NOT NULL
      ) AS expected_provider_ids
    GET_EXPECTED_PROVIDER_IDS_SQL

    provider_ids_do_not_match_sql = <<~COMPARE_ARRAYS_AS_SETS.squish
      NOT(
        provider_ids @> expected_provider_ids
        AND expected_provider_ids @> provider_ids
      )
    COMPARE_ARRAYS_AS_SETS

    ApplicationChoice
      .with(with_expected_provider_ids: with_course_joins.select(get_expected_provider_ids_sql))
      .joins('INNER JOIN with_expected_provider_ids ON application_choices.id = with_expected_provider_ids.id')
      .where(provider_ids_do_not_match_sql)
      .select('application_choices.*, expected_provider_ids')
  end
end
