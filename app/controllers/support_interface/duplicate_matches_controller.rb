module SupportInterface
  class DuplicateMatchesController < SupportInterfaceController
    PAGY_PER_PAGE = 100

    def index
      authorize(nil, :show?, policy_class: SupportInterface::CandidatePolicy)

      @filter = SupportInterface::DuplicateMatchesFilter.new(params:)

      matches_scope = if @filter.applied_filters[:query].present?
                        duplicate_matches(resolved: resolved?).joins(:candidates).where('CONCAT(email_address) ILIKE ?', "%#{@filter.applied_filters[:query]}%")
                      else
                        duplicate_matches(resolved: resolved?)
                      end

      @pagy, @matches = pagy(matches_scope, limit: PAGY_PER_PAGE)
      @under_review_count = duplicate_matches(resolved: false).count
    end

    def show
      authorize(nil, :show?, policy_class: SupportInterface::CandidatePolicy)

      @match = DuplicateMatch.find(params.expect(:id))
    end

    def update
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      @match = DuplicateMatch.find(params.expect(:id))
      @match.update(resolved: resolved_params)
      redirect_to support_interface_duplicate_match_path(@match)
    end

    def resolved?
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      resolved_params.present?
    end
    helper_method :resolved?

  private

    def resolved_params
      ActiveModel::Type::Boolean.new.cast(params[:resolved])
    end

    def duplicate_matches(resolved: false)
      DuplicateMatch.where(
        resolved:,
      ).order(created_at: :desc)
    end
  end
end
