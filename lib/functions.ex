defmodule GracefulGenServer.Functions do
  require Logger

  @doc """
  This function initiates genserver. 

  Keyword options:
    - `:do` - callback invoked with init args. Should return init state
    - `:as` - optional name, triggering logging
  """
  def init(args, opts) do
    action = Keyword.fetch!(opts, :do)
    Process.flag(:trap_exit, true)

    args
    |> tap(&log_starting(&1, opts[:as]))
    |> then(action)
    |> tap(&log_started(&1, opts[:as]))
    |> ok()
  end

  @doc """
  Termination handler.  

  Keyword options:
    - `:on_exit` - optional callback invoked when process exits. `on_exit(reason, state)`
    - `:as` - optional name, triggering logging
  """
  def terminate(reason, state, opts) do
    log_exiting({:terminate, reason}, opts[:as])

    if is_function(opts[:on_exit]) do
      opts[:on_exit].(reason, state)
    end

    state
  end

  @doc """
  Handle info message.

  Keyword options:
    - `:on_msg` - optional callback invoked when message is received. `on_msg(msg, state)`. Should return `handle_info` result.
    - `:on_exit` - optional callback invoked when process exits. `on_exit(reason, state)`
    - `:as` - optional name, triggering logging
  """
  def handle_info(msg, state, opts) do
    case msg do
      {:EXIT, from, _} when is_port(from) ->
        state |> noreply()

      {:EXIT, _from, :normal} ->
        state |> noreply()

      {:EXIT, from, reason} ->
        log_and_exit({from, reason}, state, opts[:on_exit], opts[:as])

      msg ->
        route_message_handling(msg, state, opts[:on_msg])
    end
  end

  defp log_and_exit({from, reason}, state, on_exit, as) do
    log_exiting({from, reason}, as)

    if is_function(on_exit) do
      on_exit.(reason, state)
    end

    {:stop, reason, state}
  end

  defp route_message_handling(_, state, nil), do: noreply(state)
  defp route_message_handling(msg, state, action), do: action.(msg, state)

  defp ok(x), do: {:ok, x}
  defp noreply(x), do: {:noreply, x}

  defp log_starting(args, who) do
    if who do
      [inspect(who), " is starting w/ args: ", inspect(args, pretty: true)]
      |> Logger.debug()
    end
  end

  defp log_started(state, who) do
    if who do
      [inspect(who), " started w/ state: ", inspect(state, pretty: true, limit: 7)]
      |> Logger.debug()
    end
  end

  defp log_exiting({from, reason}, who) do
    if who do
      [
        inspect(who),
        " terminated from ",
        inspect(from),
        " w/ reason: ",
        inspect(reason, pretty: true)
      ]
      |> Logger.debug()
    end
  end
end
