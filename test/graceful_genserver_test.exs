defmodule GracefulGenServerTest do
  use ExUnit.Case

  test "should start and work for some time" do
    {time, {:ok, srv}} =
      :timer.tc(fn ->
        GracefulGenServerTest.Example.Minimal.start_link([])
      end)

    assert is_pid(srv)
    assert Process.alive?(srv)
    assert time > 1500 * 1000
  end

  test "should fail if timeout is exceeded" do
    assert {:error, :timeout} = GracefulGenServerTest.Example.StartTimeouting.start_link([])
  end
end

defmodule GracefulGenServerTest.Example.StartTimeouting do
  use GracefulGenServer, timeout: 1000

  @impl true
  def on_init(_args), do: Process.sleep(1550)

  @impl true
  def on_exit(_reason, _state), do: :ok
end

defmodule GracefulGenServerTest.Example.Minimal do
  use GracefulGenServer, timeout: 2000

  @impl true
  def on_init(_args), do: Process.sleep(1500)

  @impl true
  def on_exit(_reason, _state), do: :ok
end
