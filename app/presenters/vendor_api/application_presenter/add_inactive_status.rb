module VendorAPI::ApplicationPresenter::AddInactiveStatus
  def schema
    super.deep_merge(
      attributes: {
        inactive: @application_choice.inactive?,
      },
    )
  end
end
