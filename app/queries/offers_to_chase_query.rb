# Query to return ApplicationChoices with offers whose offers have been issued
# within an interval and whose candidates have not received emails chasing a
# decision
class OffersToChaseQuery
  VALID_INTERVALS = [10, 20, 30, 40, 50].freeze

  def self.call(days:)
    raise ArgumentError unless days.in?(VALID_INTERVALS)

    chaser_type = "offer_#{days}_day"
    offset = 10
    range = ((days + offset).days.ago..days.days.ago)

    ApplicationChoice
      .joins(:offer)
      .where.not(id: ChaserSent.send(chaser_type).select(:chased_id).where(chased_type: 'ApplicationChoice'))
      .where('offers.created_at': range)
  end
end
