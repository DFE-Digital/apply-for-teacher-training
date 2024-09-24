module ApplyConsole
  def start
    show_warning_message_about_environments
    setup_console

    return run_console if HostingEnvironment.development?

    audit_and_run_console
  end

  def run_console
    IRB::Irb.new.run(IRB.conf)
  end

  def audit_and_run_console
    puts 'Hello! Who are you? This name will be used in the audit log for any changes you make.'
    who_are_you = $stdin.gets
    audited_user = "#{who_are_you.chomp} via the Rails console"
    puts "Any updates to models will be attributed in the audit logs to #{audited_user.inspect}"

    Audited.audit_class.as_user(audited_user) do
      IRB::Irb.new.run(IRB.conf)
    end
  end

  def setup_console
    IRB.setup(nil)
    IRB.conf[:USE_AUTOCOMPLETE] = false
    custom_prompt = ConsolePrompt.generate_prompt

    IRB.conf[:PROMPT][:Apply] = {
      PROMPT_I: custom_prompt,
      PROMPT_N: custom_prompt,
      PROMPT_S: nil,
      PROMPT_C: nil,
      RETURN: "=> %s\n",
    }

    IRB.conf[:PROMPT_MODE] = :Apply

    if defined?(Pry)
      apply_prompt = Pry::Prompt.new(
        'apply_prompt',
        'Custom prompt for Apply',
        [
          proc { ConsolePrompt.generate_prompt },
          proc { ConsolePrompt.generate_prompt.gsub('> ', '| ') },
        ],
      )

      Pry.config.prompt = apply_prompt
    end
  end

  def show_warning_message_about_environments
    if HostingEnvironment.production?
      puts ('*' * 50).red
      puts '** You are in the Rails console for PRODUCTION! **'.red
      puts ('*' * 50).red
    else
      puts ('-' * 65).light_blue
      puts "-- This is the Rails console for the #{HostingEnvironment.environment_name} environment. --".light_blue
      puts ('-' * 65).light_blue
    end
  end
end

class ConsolePrompt
  def self.generate_prompt(app_name: 'Apply/Manage')
    environment = HostingEnvironment.environment_name.send(env_color)

    "#{app_name} (#{environment})> "
  end

  def self.env_color
    return :red if HostingEnvironment.production?

    if HostingEnvironment.development?
      :light_green
    else
      :yellow
    end
  end
end

if defined?(Rails::Console)
  Rails::Console.prepend(ApplyConsole)
end
