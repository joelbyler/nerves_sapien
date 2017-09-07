defmodule Firmware.Application do
  use Application

  @kernel_module "brcmfmac"
  @interface :wlan0
  @wifi_cfg Application.get_env(:nerves_network, :default)

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    import Sapien.Controller

    # Define workers and child supervisors to be supervised
    children = [
      worker(Task, [fn -> init_kernel_modules() end], restart: :transient, id: Nerves.Init.KernelModules),
      worker(Task, [fn -> init_ntpd() end], restart: :transient),
      worker(Task, [fn -> init_pigpio() end], restart: :transient),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Firmware.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init_kernel_modules() do
    {_, 0} = System.cmd("modprobe", [@kernel_module])
  end

  def init_ntpd() do
    Process.sleep(8000)
    System.cmd("ntpd", ["-q", "-p", "pool.ntp.org"])
  end

  def init_pigpio do
    {_, 0} = System.cmd("pigpiod", [])
    Process.sleep(8000)

    Sapien.Controller.send_command(:sound_wake_up)

    # Sapien.Controller.start_link



    # gpio = 21
    #
    # # pulses = [%Pigpiox.Waveform.Pulse{gpio_on: gpio, delay: 500000}, %Pigpiox.Waveform.Pulse{gpio_off: gpio, delay: 500000}]
    # pulses = Firmware.Robo.send_command(:sound_wake_up, gpio)
    #
    # Pigpiox.Waveform.add_generic(pulses)
    #
    # {:ok, wave_id} = Pigpiox.Waveform.create()
    #
    # Pigpiox.GPIO.set_mode(gpio, :output)
    # Pigpiox.GPIO.write(gpio, 1)
    # IO.puts "Initializing bot"
    # # Pigpiox.Waveform.repeat(wave_id)
    #
    # wake_up = Task.async(fn -> Pigpiox.Waveform.send(wave_id) end)
    # IO.puts "Result of command: {:#{Enum.join(Tuple.to_list(Task.await(wake_up)), ", ")}}"
    #
    # # Pigpiox.Waveform.send(wave_id)
    # IO.puts "Resetting for next command"
    # Pigpiox.GPIO.write(gpio, 1)
  end
end
