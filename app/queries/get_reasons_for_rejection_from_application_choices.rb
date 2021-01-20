class GetReasonsForRejectionFromApplicationChoices
  def count_sql(date)
    "SELECT reasons.key AS key,
      CASE
        WHEN rejected_at > '#{date}' THEN
          'this_month'
        ELSE
          'before_this_month'
      END AS time_period,
      count(*)
    FROM application_choices,
      jsonb_each_text(structured_rejection_reasons) AS reasons
    WHERE structured_rejection_reasons IS NOT NULL
      AND reasons.value = 'Yes'
    GROUP BY (key, time_period);"
  end
end
