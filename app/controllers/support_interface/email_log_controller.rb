module SupportInterface
  class EmailLogController < SupportInterfaceController
    PAGY_PER_PAGE = 30

    def index
      @filter = SupportInterface::EmailsFilter.new(params:)

      emails = if @filter.filtered?
        EmailQuery.call(params: @filter.applied_filters)
      else
        Email.none
      end

      @pagy, @emails = pagy(emails, limit: PAGY_PER_PAGE)
    end
  end
end
