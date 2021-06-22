module SupportInterface
  class MultipleProviderUsersWizard
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :provider_id,
                  :state_store,
                  :provider_users

    attr_reader :index

    validates :provider_users, presence: true

    class << self
      def build(state_store:, provider_id:)
        new(
          state_store: state_store,
          provider_id: provider_id,
          provider_users: provider_users(state_store),
        )
      end

    private

      def provider_users(state_store)
        state = state_store.read
        stored_provider_users = JSON.parse(state)['provider_users'] if state
        create_csv_row = ->(user) { "#{[user['first_name'], user['last_name'], user['email_address']].compact.join(',')}\n" }
        stored_provider_users&.map { |user| create_csv_row.call(user) }&.join
      end
    end

    def index=(index)
      @index = index.to_i
    end

    def clear_state!
      @state_store.delete
    end

    def save_users_to_state_store!
      state_store.write(prepare_provider_users_for_state_store)
    end

    def save_user_to_state_store!(single_provider_user_form)
      state_store.write(prepare_provider_user_for_state_store(single_provider_user_form))
    end

    def all_single_provider_user_forms
      provider_users = read_state['provider_users']

      provider_users.map.with_index do |provider_user, index|
        SupportInterface::CreateSingleProviderUserForm.new(
          index: index,
          provider_id: provider_id,
          first_name: provider_user['first_name'],
          last_name: provider_user['last_name'],
          email_address: provider_user['email_address'],
          provider_permissions: {
            provider_permission: provider_user['permissions'].symbolize_keys,
          },
        )
      end
    end

    def stored_provider_users
      read_state['provider_users']
    end

    def provider_user_count
      read_state['provider_users'].length
    end

    def position_and_count
      {
        position: index + 1,
        count: provider_user_count,
      }
    end

    def next_position
      index + 2
    end

    def more_users_to_process?
      read_state['provider_users'].select { |pu| pu['complete'] == false }.present?
    end

    def single_provider_user_form(index)
      provider_user = read_state['provider_users'][index]
      form = SupportInterface::CreateSingleProviderUserForm.new(
        index: index,
        provider_id: provider_id,
        first_name: provider_user['first_name'],
        last_name: provider_user['last_name'],
        email_address: provider_user['email_address'],
      )

      if provider_user['permissions']
        form.provider_permissions = { provider_permission: provider_user['permissions'].symbolize_keys }
      end

      form
    end

    def provider_user_name
      state = read_state
      provider_user = state['provider_users'].first

      "#{provider_user['first_name']} #{provider_user['last_name']}"
    end

  private

    def prepare_provider_users_for_state_store
      provider_user_array_hash = provider_users
        .split("\r\n")
        .map { |row| row.split(/[\t,]+/) }
        .map do |provider_user|
        {
          first_name: provider_user[0],
          last_name: provider_user[1],
          email_address: provider_user[2],
          complete: false,
        }
      end

      {
        provider_users: provider_user_array_hash,
      }.to_json
    end

    def prepare_provider_user_for_state_store(form)
      state = read_state
      updated_user_details = {
        first_name: form.first_name,
        last_name: form.last_name,
        email_address: form.email_address,
        permissions: form.permission_form.provider_permission,
        complete: true,
      }

      state['provider_users'][form.index] = updated_user_details

      clear_state!
      state.to_json
    end

    def read_state
      JSON.parse(state_store.read)
    end
  end
end
