SELECT
  application_choices.*,

  original_course.id AS original_course_id,
  original_option.id AS original_option_id,
  original_option.site_id AS original_site_id,
  original_course.recruitment_cycle_year AS original_course_year,
  original_course.provider_id AS original_training_provider_id,
  COALESCE(original_course.accredited_provider_id, original_course.provider_id)
    AS original_ratifying_provider_id,

  current_course.id AS current_course_id,
  current_option.id AS current_option_id,
  current_option.site_id AS current_site_id,
  current_course.recruitment_cycle_year AS current_course_year,
  current_course.provider_id AS current_training_provider_id,
  COALESCE(current_course.accredited_provider_id, current_course.provider_id)
    AS current_ratifying_provider_id

FROM application_choices

INNER JOIN course_options AS original_option
  ON course_option_id = original_option.id

INNER JOIN course_options AS current_option
  ON COALESCE(offered_course_option_id, course_option_id) = current_option.id

INNER JOIN courses AS original_course
  ON original_option.course_id = original_course.id

INNER JOIN courses AS current_course
  ON current_option.course_id = current_course.id
