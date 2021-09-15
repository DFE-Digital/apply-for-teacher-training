desc 'Creates a number of persona provider user accounts'
task create_persona_users: :environment do
  puts 'Creating personas...'
  CreatePersonaUsers.call
end
