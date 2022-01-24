module VendorAPI
  module Changes
    class WithdrawOrDeclineApplication < VersionChange
      description \
        'Withdraw an application\n' \
        'Withdraws an application or declines an offer at the candidate‘s request' \

      resource ApplicationPresenter, [WithdrawOrDeclineApplicationAPIData]
    end
  end
end
