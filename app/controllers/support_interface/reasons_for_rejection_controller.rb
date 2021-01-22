module SupportInterface
  class ReasonsForRejectionController < SupportInterfaceController
    def sub_reasons
      @reasons = ReasonsForRejectionCountQuery.new.sub_reason_counts
    end
  end
end
