class FindInterface::SiteDecorator < Draper::Decorator
  delegate_all

  def full_address
    [object.address1, object.address2, object.address3, object.address4, object.postcode].select(&:present?).join(", ").html_safe
  end
end
