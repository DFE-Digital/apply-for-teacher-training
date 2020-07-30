class EndOfCycleTimetable
  DATES = {
    2020 => {
      apply_1_cutoff: Date.new(2020, 8, 24),
      apply_2_cutoff: Date.new(2020, 9, 18),
      reopen: Date.new(2020, 10, 13),
    }.with_indifferent_access,
  }.freeze

  def self.submissions_closed_for?(application_form, time = Time.zone.today)
    if application_form.apply_1?
      time > apply_1_cutoff && time < reopen
    else
      time > apply_2_cutoff && time < reopen
    end
  end

  def self.apply_1_cutoff
    date_in_current_year_for(:apply_1_cutoff)
  end

  def self.apply_2_cutoff
    date_in_current_year_for(:apply_2_cutoff)
  end

  def self.reopen
    date_in_current_year_for(:reopen)
  end

  def self.date_in_current_year_for(event)
    year = Time.zone.today.year
    DATES[year][event]
  end
end
