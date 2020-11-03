module ApplyConsole
  def start
    show_warning_message_about_environments
    super
  end

  def show_warning_message_about_environments
    if HostingEnvironment.production?
      puts ("*" * 50).red
      puts "** You are in the Rails console for PRODUCTION! **".red
      puts ("*" * 50).red
    else
      puts ("-" * 65).blue
      puts "-- This is the Rails console for the #{HostingEnvironment.environment_name} environment. --".blue
      puts ("-" * 65).blue
    end
  end
end

module Rails
  class Console
    prepend ApplyConsole
  end
end
