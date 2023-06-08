defmodule GracefulGenServer do
  @moduledoc """
  Handles init and terminate of genserver.

  This wraps GenServer callbacks to provide the functionality.
    - on_init wraps init callback
    - on_exit wraps terminate callback
    - on_msg wraps handle_info callback

  The rest of GenServer callbacks are free to use

  ## Examples
      defmodule MyApp.Server do
        use GracefulGenServer

        def on_init(init_args) do
          ...
          initial_state
        end

        # optional
        def on_msg(info_msg, state) do
          ...
          {:noreply, new_state} # or any legit handle_info/2 response
        end

        def on_exit(reason, state) do
          ...
        end
      end
  """

  @callback on_init(args :: any) :: any
  @callback on_exit(reason :: any, state :: any) :: any
  @callback on_msg(msg :: any, state :: any) ::
              {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term}}
              | {:stop, reason :: term, new_state}
            when new_state: term

  @optional_callbacks on_msg: 2

  defmacro __using__(start_opts) do
    quote location: :keep, bind_quoted: [start_opts: start_opts] do
      @behaviour GracefulGenServer
      use GenServer

      alias GracefulGenServer.Functions, as: Graceful

      def start_link(args) do
        GenServer.start_link(__MODULE__, args, unquote(Macro.escape(start_opts)))
      end

      @impl true
      def init(args), do: Graceful.init(args, do: &on_init/1, as: __MODULE__)

      @impl true
      def handle_info(msg, state),
        do:
          Graceful.handle_info(msg, state,
            on_exit: &on_exit/2,
            on_msg: &on_msg/2,
            as: __MODULE__
          )

      @impl true
      def terminate(reason, state),
        do: Graceful.terminate(reason, state, on_exit: &on_exit/2, as: __MODULE__)

      @doc false
      def on_msg(_msg, state), do: {:noreply, state}

      defoverridable on_msg: 2
    end
  end
end
