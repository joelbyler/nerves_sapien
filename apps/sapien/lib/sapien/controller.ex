defmodule Sapien.Controller do
  use GenServer

  # Client API

  def start_link(pin \\ 21, adapter \\ Sapien.Adapter.Fake) do
    initial_state = [
      pin: pin,
      adapter: adapter
    ]

    {:ok, pid} = GenServer.start_link(__MODULE__, initial_state, [])
  end

  def send_command(command) do
    GenServer.call(:send_command, command)
  end

  # Server implementation

  def init(args) do
    [{:pin, pin}, {:adapter, adapter}] = args

    IO.puts "Initializing bot"
    Sapien.Command.send_message(adapter, GPIO, :set_mode, [pin, :output])
    Sapien.Command.send_message(adapter, GPIO, :write, [pin, 1])

    {:ok, %{pin: pin, adapter: adapter}}
  end

  def handle_call({:send_command, command}, _from, state) do
    pulses = Sapien.Command.pulses_for_command(state.adapter, command, state.pin)
    Sapien.Command.send_message(state.adapter, Waveform, :add_generic, [pulses])

    {:ok, wave_id} = Sapien.Command.send_message(state.adapter, Waveform, :create, [])
    IO.puts "Sending command #{command}"

    send_command = Task.async(fn -> Sapien.Command.send_message(state.adapter, Waveform, :send, [wave_id]) end)
    command_result = Task.await(send_command)
    IO.puts "Result of command: {:#{Enum.join(Tuple.to_list(command_result), ", ")}}"

    {:ok, _} = Sapien.Command.send_message(state.adapter, GPIO, :write, [state.pin, 1])
    IO.puts "Reset for next command"

    {:reply, command_result, state}
  end
end
