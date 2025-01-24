class EndOfCycleBannersComponent < ViewComponent::Base
  EndOfCycleBanner = Struct.new(:name, :date, keyword_init: true)

  def end_of_cycle_banners
    Array.wrap(
      EndOfCycleBanner.new(
        name: 'Apply deadline banner',
        date: "#{deadline_approaching_banner_date} to #{apply_deadline}",
      ),
    )
  end

private

  def deadline_approaching_banner_date
    CycleTimetable.date(:show_deadline_banner).strftime('%e %B %Y')
  end

  def apply_deadline
    CycleTimetable.apply_deadline.strftime('%e %B %Y')
  end
end
