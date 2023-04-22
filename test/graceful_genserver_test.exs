defmodule GracefulGenserverTest do
  use ExUnit.Case
  doctest GracefulGenserver

  test "greets the world" do
    assert GracefulGenserver.hello() == :world
  end
end
