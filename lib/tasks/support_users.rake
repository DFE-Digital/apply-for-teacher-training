desc 'Create a new support user (if he/she doesn not already exist)'
task :create_support_user, %i[dfe_sign_in_uid email_address] => [:environment] do |_t, args|
  CreateSupportUser.new(
    dfe_sign_in_uid: args[:dfe_sign_in_uid],
    email_address: args[:email_address],
  ).call
end
