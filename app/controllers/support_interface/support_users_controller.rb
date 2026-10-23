module SupportInterface
  class SupportUsersController < SupportInterfaceController
    def index
      authorize(nil, policy_class: SupportInterface::SupportUserPolicy)

      unsorted_support_users = params[:removed] == 'true' ? SupportUser.discarded : SupportUser.kept
      @support_users = unsorted_support_users.order!(last_signed_in_at: :asc)
    end

    def show
      @support_user = SupportUser.find(params.expect(:id))

      authorize(@support_user, policy_class: SupportInterface::SupportUserPolicy)
    end

    def new
      @support_user = SupportUser.new

      authorize(@support_user, policy_class: SupportInterface::SupportUserPolicy)
    end

    def create
      @support_user = SupportUser.new(support_user_params)

      authorize(@support_user, policy_class: SupportInterface::SupportUserPolicy)

      if @support_user.save
        flash[:success] = 'Support user created'
        redirect_to support_interface_support_users_path
      else
        render :new
      end
    end

    def confirm_destroy
      @support_user = SupportUser.find(params.expect(:id))

      authorize(@support_user, :destroy?, policy_class: SupportInterface::SupportUserPolicy)
    end

    def confirm_restore
      @support_user = SupportUser.find(params.expect(:id))

      authorize(@support_user, :edit?, policy_class: SupportInterface::SupportUserPolicy)
    end

    def destroy
      @support_user = SupportUser.find(params.expect(:id))

      authorize(@support_user, :destroy?, policy_class: SupportInterface::SupportUserPolicy)

      @support_user.destroy
      flash[:success] = 'Support user removed'
      redirect_to support_interface_support_users_path
    end

    def restore
      @support_user = SupportUser.find(params.expect(:id))

      authorize(@support_user, :edit?, policy_class: SupportInterface::SupportUserPolicy)

      @support_user.undiscard
      flash[:success] = 'Support user restored'
      redirect_to support_interface_support_users_path
    end

  private

    def support_user_params
      params.expect(support_user: %i[email_address dfe_sign_in_uid])
    end
  end
end
