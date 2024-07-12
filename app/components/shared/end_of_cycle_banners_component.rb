class EndOfCycleBannersComponent < ViewComponent::Base
  EndOfCycleBanner = Struct.new(:name, :date, keyword_init: true)

  def end_of_cycle_banners
    [
      {
        name: 'Summer recruitment banner',
        date: "#{banner_date(:show_summer_recruitment_banner)} to #{banner_date(:apply_deadline)}",
      },
      {
        name: 'Apply deadline banner',
        date: "#{banner_date(:show_deadline_banner)} to #{banner_date(:apply_deadline)}",
      },
    ].map do |cycle_data|
      EndOfCycleBanner.new(cycle_data)
    end
  end

private

  def banner_date(banner_label)
    CycleTimetable.date(banner_label).strftime('%e %B %Y')
  end
end
