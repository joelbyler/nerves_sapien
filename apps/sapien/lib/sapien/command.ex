defmodule Sapien.Command do
  @available_commands %{
    right_turn:        128,
    right_arm_up:      129,
    right_arm_out:     130,
    right_body_tilt:   131,
    right_arm_down:    132,
    right_arm_in:      133,
    walk_forward:      134,
    walk_backward:     135,
    left_turn:         136,
    left_arm_up:       137,
    left_arm_out:      138,
    left_body_tilt:    139,
    left_arm_down:     140,
    left_arm_in:       141,
    stop:              142,
    sound_wake_up:     143,
    sound_burp:        144,
    right_hand_strike: 145,
    no_op:             146,
  }

  @cycle 833

# Firmware.Robo.send_command(:stop, 21)

  def binary_string_wave(adapter, binary_string, pin) do
    wave = [] ++ head(adapter, pin)
    wave = wave ++ Enum.map(String.splitter(binary_string, ""), fn(x) -> signal(adapter, pin, x) end)
    wave = wave ++ tail(adapter, pin)
    List.flatten(wave) |> Enum.filter(fn(x) -> x != nil end)
  end

  def send_command(adapter, command, pin) do
    {:ok, code} = command_code(command)
    code_binary_string(code) |> binary_string_wave(adapter, pin)
  end

  def command_code(command) do
    Map.fetch(@available_commands, command)
  end

  def code_binary_string(code) do
    Integer.to_string(code, 2) |> String.pad_leading(8, "0")
  end
# code = 34
# binary_string = Integer.to_string(code, 2) |> String.pad_leading(8, "0")
# mapped_array = Enum.map(String.splitter(binary_string, ""), fn(x) -> "x#{x}" end)



  def head(adapter, pin) do
    add_wave(adapter, pin, 8, 8)
  end

  def signal(adapter, pin, "1") do
    add_wave(adapter, pin, 4, 1)
  end

  def signal(adapter, pin, "0") do
    add_wave(adapter, pin, 1, 1)
  end

  def signal(adapter, pin, _) do

  end

  def tail(adapter, pin) do
    add_wave(adapter, pin, 8, 8)
  end

  def add_wave(adapter, pin, hi, lo) do
    [
      build_pulse(adapter, on: pin, delay: hi * @cycle),
      build_pulse(adapter, off: pin, delay: lo * @cycle)
    ]
  end


  #  notes below
  #
	# def add_wave(hi, lo) do
  #   [
  #     %Pigpiox.Waveform.Pulse{gpio_on: pin, delay: hi * @cycle},
  #     %Pigpiox.Waveform.Pulse{gpio_off: pin, delay: low * @cycle}
  #   ]
  # end
  #
  # def head_wave do
  #   add_wave(8, 8)
  # end
  #
  #
  # def create_code(code):
  #   Integer.to_string(code, 2) |> String.pad_leading(8, "0")
  #
	# 	data = code
	# 	wave = [] ++ head_wave
  #
	# 	for x in range(8):
	# 		if (data & 128 != 0):
	# 			wave.append(self.wf_hi)
	# 			print 1
	# 		else:
	# 			wave.append(self.wf_lo)
	# 			print 0
	# 		data <<= 1
  #
	# 	wave.append(self.wf_tail)
	# 	print wave
	# 	print "end"
	# 	return wave
  # end
  #
	# def send_code(command, pin) do
	# 	send_wave(create_code(code))
  #   Process.sleep(500)
  # end
  #
  # def send_command(command, pin) do
  #
  #   Pigpiox.Waveform.add_generic(add_wave(hi, lo))
  #
  #   {:ok, wave_id} = Pigpiox.Waveform.create()
  #
  #   Pigpiox.GPIO.set_mode(gpio, :output)
  #
  #   Pigpiox.Waveform.send(wave_id)
  # end

  @adapter Application.get_env(:sapien, :adapter)

  def send_message(adapter, module, function, args) do
    apply(Module.concat(adapter, module), function, args)
  end

  def build_pulse(adapter, %{on: pin, delay: delay}) do
    struct(Module.concat(Module.concat(adapter, Waveform), Pulse), [gpio_on: pin, delay: delay])
  end

  def build_pulse(adapter, %{off: pin, delay: delay}) do
    struct(Module.concat(Module.concat(adapter, Waveform), Pulse), [gpio_off: pin, delay: delay])
  end

  def adapter do
    @adapter || Pigpiox
  end
end
