class StateDiagram
  def self.svg(machine:, only_from_state: nil)
    namespace = machine.i18n_namespace
    graph = GraphViz.new('G', rankdir: 'TB', ratio: 'fill')

    states_to_show = []

    machine.workflow_spec.states.each do |_, state|
      next if only_from_state && state.name != only_from_state.to_sym

      state.events.flat.each do |event|
        states_to_show << state.name
        states_to_show << event.transitions_to

        graph.add_edges(
          state.name.to_s,
          event.transitions_to.to_s,
          label: "#{event_emoji(state.name, event, namespace)} #{event_name(state.name, event, namespace)}",
          fontname: 'GDS Transport", arial, sans-serif',
          color: '#0b0c0c',
          fontcolor: '#0b0c0c',
          fontsize: 12,
          tooltip: I18n.t!("#{namespace}events.#{state}-#{event}.description"),
        )
      end
    end

    states_to_show.flatten!
    states_to_show.uniq!

    machine.workflow_spec.states.each do |state_name, state|
      if only_from_state && !(only_from_state.to_sym == state.name || state.name.to_sym.in?(states_to_show))
        next
      end

      graph.add_nodes(
        state_name.to_s,
        label: I18n.t!("#{namespace}application_states.#{state_name}.name"),
        width: '0.5',
        height: '0.5',
        shape: 'rect',
        style: 'filled',
        color: '#1d70b8',
        fontcolor: '#ffffff',
        fontname: 'GDS Transport", arial, sans-serif',
        fontsize: 15,
        margin: 0.2,
        tooltip: I18n.t!("#{namespace}application_states.#{state_name}.description"),
        URL: "##{state_name}",
      )
    end

    if graph.node_count > 3 && only_from_state
      graph[:rankdir] = 'LR'
    end

    # Add negative tabindex to embedded links to prevent SVG generating illogical focus orders
    graph.output(svg: String).force_encoding('UTF-8').gsub('xlink:href', 'tabindex="-1" xlink:href').html_safe
  end

  def self.event_name(state, event, namespace)
    I18n.t!("#{namespace}events.#{state}-#{event}.name")
  end

  def self.event_emoji(state, event, namespace)
    by = I18n.t!("#{namespace}events.#{state}-#{event}.by")

    {
      'candidate' => '👩‍🎓',
      'referee' => '👩‍🏫',
      'provider' => '🏫',
      'system' => '🤖',
    }.fetch(by)
  end
end
