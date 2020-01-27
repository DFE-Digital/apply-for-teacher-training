class StateDiagram
  def self.svg(only_from_state = nil)
    graph = GraphViz.new('G', rankdir: 'TB', ratio: 'fill')

    states_to_show = []

    ApplicationStateChange.workflow_spec.states.each do |_, state|
      next if only_from_state && state.name != only_from_state.to_sym

      state.events.flat.each do |event|
        states_to_show << state.name
        states_to_show << event.transitions_to

        graph.add_edges(
          state.name.to_s,
          event.transitions_to.to_s,
          label: event_name(state.name, event),
          fontname: 'Arial',
          color: '#0b0c0c',
          fontcolor: '#0b0c0c',
          fontsize: 12,
          tooltip: I18n.t!("events.#{state}-#{event}.description"),
        )
      end
    end

    states_to_show.flatten!
    states_to_show.uniq!

    ApplicationStateChange.workflow_spec.states.each do |state_name, state|
      if only_from_state
        next unless only_from_state.to_sym == state.name || state.name.to_sym.in?(states_to_show)
      end

      graph.add_nodes(
        state_name.to_s,
        label: I18n.t!("application_states.#{state_name}.name"),
        width: '0.5',
        height: '0.5',
        shape: 'rect',
        style: 'filled',
        color: '#1d70b8',
        fontcolor: '#ffffff',
        fontname: 'Arial',
        fontsize: 15,
        margin: 0.2,
        tooltip: I18n.t!("application_states.#{state_name}.description"),
        URL: "/support/process##{state_name}",
      )
    end

    if graph.node_count > 3 && only_from_state
      graph[:rankdir] = 'LR'
    end

    graph.output(svg: String).force_encoding('UTF-8').html_safe
  end

  def self.event_name(state, event)
    by = I18n.t!("events.#{state}-#{event}.by")

    emoji = {
      'candidate' => '👩‍🎓',
      'referee' => '👩‍🏫',
      'provider' => '🏫',
      'system' => '🤖',
    }.fetch(by)

    emoji + ' ' + I18n.t!("events.#{state}-#{event}.name")
  end
end
