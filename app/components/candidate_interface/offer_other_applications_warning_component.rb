module CandidateInterface
  class OfferOtherApplicationsWarningComponent < ViewComponent::Base
    def initialize(choice_with_offer:)
      @choice_with_offer = choice_with_offer
    end

    def call
      content_tag :p, message, class: 'govuk-body'
    end

    def render?
      other_offers? || any_inflight?
    end

  private

    def message
      if other_offers?
        if inflight_with_interviews?
          t('.offers_and_inflight_with_interviews', count: other_offers_count)
        elsif any_inflight?
          t('.offers_and_inflight_without_interviews', count: other_offers_count)
        else
          t('.offers_and_no_inflight', count: other_offers_count)
        end
      elsif inflight_with_interviews?
        t('.inflight_with_interviews_and_no_offers')
      else
        t('.inflight_without_interviews_and_no_offers')
      end
    end

    def other_offers_count
      @other_offers_count ||= sibling_choices.offer.count
    end

    def other_offers?
      other_offers_count.positive?
    end

    def inflight_with_interviews?
      inflight_choices.joins(:interviews)
        .where('interviews.date_and_time >= ?', Time.zone.now)
        .uniq.any?
    end

    def any_inflight?
      inflight_choices.any?
    end

    def inflight_choices
      @inflight_choices ||= sibling_choices.where(status: ApplicationStateChange::INTERVIEWABLE_STATES)
    end

    def sibling_choices
      @sibling_choices ||= @choice_with_offer.siblings
    end
  end
end
