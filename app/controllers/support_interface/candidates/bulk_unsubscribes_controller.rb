class SupportInterface::Candidates::BulkUnsubscribesController < SupportInterface::SupportInterfaceController
  def new
    @bulk_unsubscribe_form = SupportInterface::Candidates::BulkUnsubscribeForm.new
  end

  def create
    @bulk_unsubscribe_form = SupportInterface::Candidates::BulkUnsubscribeForm.new(bulk_unsubscribe_params)

    if @bulk_unsubscribe_form.save
      flash[:success] = 'Candidates unsubscribed'
      redirect_to support_interface_path
    else
      render :new
    end
  end

private

  def bulk_unsubscribe_params
    params.expect(
      bulk_unsubscribe: %i[email_addresses audit_comment],
    ).merge(audit_user:)
  end
end
