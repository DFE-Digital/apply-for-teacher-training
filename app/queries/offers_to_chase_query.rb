# Query to return ApplicationChoices with offers whose offers have been issued
# within an interval and whose candidates have not received emails chasing a
# decision
class OffersToChaseQuery
  def self.call(chaser_type:, date_range:)
    ApplicationChoice
      .offer
      .where.not(id: ChaserSent.send(chaser_type).select(:chased_id).where(chased_type: 'ApplicationChoice'))
      .where(current_recruitment_cycle_year: CycleTimetable.current_year)
      .where('application_choices.offered_at': date_range)
  end
end
