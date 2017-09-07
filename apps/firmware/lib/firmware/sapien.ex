# defmodule Firmware.Sapien do
#   use GenServer
#
#   # Client API
#
#   def start_link(pin \\ 21, adapter \\ Pigpiox) do
#     initial_state = [
#       pin: pin,
#       adapter: adapter
#     ]
#
#     {:ok, pid} = GenServer.start_link(__MODULE__, initial_state, opts)
#   end
#
#   def send_command(command) do
#     GenServer.call(:send_command, command)
#   end
#
#   # Server implementation
#
#   def init(args) do
#     [{:pin, pin}, {:adapter, adapter}] = args
#
#     adapter.GPIO.write(pin, 1)
#     IO.puts "Initializing bot"
#
#     {:ok, %{pin: pin, adapter: adapter}}
#   end
#
#   def handle_call({:send_command, mac}, _from, state) do
#     %{ets_table_name: ets_table_name} = state
#     result = :ets.lookup(ets_table_name, mac)++[{mac, nil}] |> hd |> map_to_connection
#     {:reply, result, state}
#   end
# end
