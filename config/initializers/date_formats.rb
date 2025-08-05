Time::DATE_FORMATS[:govuk_date] = '%-d %B %Y'
Time::DATE_FORMATS[:govuk_date_short_month] = '%-d %b %Y'
Date::DATE_FORMATS[:govuk_date] = '%-d %B %Y'
Date::DATE_FORMATS[:govuk_date_short_month] = '%-d %b %Y'

Time::DATE_FORMATS[:month_and_year] = '%B %Y'
Date::DATE_FORMATS[:month_and_year] = '%B %Y'

Time::DATE_FORMATS[:short_month_and_year] = '%b %Y'
Date::DATE_FORMATS[:short_month_and_year] = '%b %Y'

Time::DATE_FORMATS[:day_and_month] = '%-d %B'
Date::DATE_FORMATS[:day_and_month] = '%-d %B'

Time::DATE_FORMATS[:govuk_date_and_time] = lambda do |time|
  format = if time.between?(time.midday, time.midday.end_of_minute)
             '%e %B %Y at %l%P (midday)'
           elsif time.between?(time.midnight, time.midnight.end_of_minute)
             '%e %B %Y at %l%P (midnight)'
           elsif time.min.zero?
             '%e %B %Y at %l%P'
           else
             '%e %B %Y at %l:%M%P'
           end

  "#{time.strftime(format).squish} UK time"
end

Time::DATE_FORMATS[:govuk_time] = lambda do |time|
  format = if time.between?(time.midday, time.midday.end_of_minute)
             '%l%P (midday)'
           elsif time.between?(time.midnight, time.midnight.end_of_minute)
             '%l%P (midnight)'
           elsif time.min.zero?
             '%l%P'
           else
             '%l:%M%P'
           end

  "#{time.strftime(format).squish} UK time"
end

Time::DATE_FORMATS[:govuk_time_first_no_year_date_time] = lambda do |time|
  "#{time.to_fs(:govuk_time)} on #{time.to_fs(:day_and_month)}"
end

Date::DATE_FORMATS[:govuk_time_first_no_year_date_time] = lambda do |time|
  "#{time.to_fs(:govuk_time)} on #{time.to_fs(:day_and_month)}"
end

Time::DATE_FORMATS[:govuk_time_first_no_year_date_time] = lambda do |time|
  "#{time.to_fs(:govuk_time)} on #{time.to_fs(:day_and_month)}"
end

Date::DATE_FORMATS[:govuk_date_time_time_first] = lambda do |time|
  "#{time.to_fs(:govuk_time)} on #{time.to_fs(:govuk_date)}"
end

Time::DATE_FORMATS[:govuk_date_time_time_first] = lambda do |time|
  "#{time.to_fs(:govuk_time)} on #{time.to_fs(:govuk_date)}"
end
