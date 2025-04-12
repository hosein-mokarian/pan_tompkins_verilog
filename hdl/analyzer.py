from vcd.reader import TokenKind, tokenize
from vcd.common import ScopeType, VarType
import matplotlib.pyplot as plt


# -----------------------------------------------------------------------------
# --- VCD File Analsis ---
def unsigned_to_signed(value, bit_width):
    # Calculate the maximum unsigned value
    max_unsigned = 2 ** bit_width

    # Check if the MSB is set (negative in two's complement)
    if value >= max_unsigned // 2:
        return value - max_unsigned
    return value
# -----------------------------------------------------------------------------

with open("qrs_results.vcd", 'rb') as vcd_file:
  reader = tokenize(vcd_file)

  flag = False
  counter = 0
  print("------------------------------------------")

  module_found_flag = False
  module_name = "uut"

  xin_ref = "xin"
  xin_id_code = "+"

  lpf_out_ref = "lpf_out"
  lpf_out_id_code = "U"

  hpf_out_ref = "hpf_out"
  hpf_out_id_code = "Z"
  
  deriv_out_ref = "deriv_out"
  deriv_out_id_code = "["

  squared_out_ref = "squared_out"
  squared_out_id_code = "9"

  integral_out_ref = "integral_out"
  integral_out_id_code = "X"

  peak_i_ref = "peak_i"
  peak_i_id_code = "M"

  spu_ref = "spu"
  spu_id_code = ";"

  regular_ref = "regular"
  regular_id_code = "G"

  xin_values = []
  xin_timestamps = []

  lpf_out_values = []
  lpf_out_timestamps = []

  hpf_out_values = []
  hpf_out_timestamps = []

  deriv_out_values = []
  deriv_out_timestamps = []

  squared_out_values = []
  squared_out_timestamps = []

  integral_out_values = []
  integral_out_timestamps = []

  peak_i_values = []
  peak_i_timestamps = []

  spu_values = []
  spu_timestamps = []

  regular_values = []
  regular_timestamps = []

  timestamp = 0

  for token in reader:
    # print(f"token: {token}")
    # print("--------------------")

    if token.kind == TokenKind.DATE:
      print(f"DATE: {token.date}")
    elif token.kind == TokenKind.TIMESCALE:
      print(f"TIMESCALE: {token.timescale}")
    elif token.kind == TokenKind.VERSION:
      print(f"VERSION: {token.version}")
    elif token.kind == TokenKind.SCOPE:
      # print(f"SCOPE: {token.data}")
      if token.data.type_ == ScopeType.module:
        # print(f"name: {token.data.type_.name}")
        # print(f"value: {token.data.type_.value}")
        # print(f"ident: {token.data.ident}")
        if token.data.ident == module_name:
          module_found_flag = True
        else:
          module_found_flag = False
    elif token.kind == TokenKind.VAR:
    #   print(f"var: {token.data}")
    #   print(f"{token.data.type_}")
    #   print(f"{token.data.size}")
    #   print(f"{token.data.id_code}")
    #   print(f"{token.data.reference}")
      if module_found_flag == True:
        if token.data.reference == xin_ref:
          xin_id_code = token.data.id_code
        elif token.data.reference == lpf_out_ref:
          lpf_out_id_code = token.data.id_code
        elif token.data.reference == hpf_out_ref:
          hpf_out_id_code = token.data.id_code
        elif token.data.reference == deriv_out_ref:
          deriv_out_id_code = token.data.id_code
        elif token.data.reference == squared_out_ref:
          squared_out_id_code = token.data.id_code
        elif token.data.reference == integral_out_ref:
          integral_out_id_code = token.data.id_code
        elif token.data.reference == peak_i_ref:
          peak_i_id_code = token.data.id_code
        elif token.data.reference == spu_ref:
          spu_id_code = token.data.id_code
        elif token.data.reference == regular_ref:
          regular_id_code = token.data.id_code
    #   print(f"{token.data.bit_index}")
      # if token.data.type_ == VarType.wire:
        # print(f"{token.data.type_}")
    # elif token.kind == TokenKind.DUMPALL:
    #   print(f"token: {token}")
    #   print("--------------------")
    #   print(f"DUMPALL: {token.data}")
    # elif token.kind == TokenKind.DUMPVARS:
    #   print(f"token: {token}")
    #   print("--------------------")
    #   print(f"DUMPVARS: {token.data}")
    elif token.kind == TokenKind.CHANGE_TIME:
      # print(f"token: {token}")
      # print("--------------------")
      # print(f"CHANGE_TIME: {token.data}")
      timestamp = token.data
      if token.data > 0:
        flag = True
      # print(f"counter: {counter}")
      # counter = counter + 1
    elif token.kind == TokenKind.CHANGE_VECTOR:
      if flag == True :
        # print(f"token: {token}")
        # print("--------------------")
        # print(f"CHANGE_VECTOR: {token.data}")
        if token.data.id_code == xin_id_code:
          xin_timestamps.append(timestamp)
          xin_values.append(token.data.value)
        elif token.data.id_code == lpf_out_id_code:
          lpf_out_timestamps.append(timestamp)
          lpf_out_values.append(token.data.value)
        elif token.data.id_code == hpf_out_id_code:
          hpf_out_timestamps.append(timestamp)
          hpf_out_values.append(token.data.value)
        elif token.data.id_code == deriv_out_id_code:
          deriv_out_timestamps.append(timestamp)
          deriv_out_values.append(token.data.value)
        elif token.data.id_code == squared_out_id_code:
          squared_out_timestamps.append(timestamp)
          squared_out_values.append(token.data.value)
        elif token.data.id_code == integral_out_id_code:
          integral_out_timestamps.append(timestamp)
          integral_out_values.append(token.data.value)
        elif token.data.id_code == peak_i_id_code:
          peak_i_timestamps.append(timestamp)
          peak_i_values.append(token.data.value)
    # elif token.kind == TokenKind.CHANGE_REAL:
    #   if flag == True :
    #     if token.data.id_code == spu_id_code:
    #       spu_timestamps.append(timestamp)
    #       spu_values.append(token.data.value)
    #       print(f"token: {token}")
    #       print("--------------------")
    #       print(f"CHANGE_REAL: {token.data}")
    elif token.kind == TokenKind.CHANGE_SCALAR:
      if flag == True :
        if token.data.id_code == spu_id_code:
          spu_timestamps.append(timestamp)
          spu_values.append(token.data.value)
          # print(f"token: {token}")
          # print("--------------------")
          # print(f"CHANGE_SCALAR: {token.data}")
        elif token.data.id_code == regular_id_code:
          regular_timestamps.append(timestamp)
          regular_values.append(token.data.value)

# CHANGE_SCALAR: Single-bit scalar signals.
# CHANGE_VECTOR: Multi-bit vector signals (e.g., buses).
# CHANGE_STRING: String-valued signals.
# CHANGE_REAL: Real-valued signals.
#  elif token.kind in {TokenKind.CHANGE_SCALAR, TokenKind.CHANGE_VECTOR, TokenKind.CHANGE_STRING, TokenKind.CHANGE_REAL}:

    # print("------------------------------------------")
    
    # counter = counter + 1
    # if (counter == 1000):
    #   break
# -----------------------------------------------------------------------------

print(f"xin_id_code: {xin_id_code}")
print(f"lpf_out_id_code: {lpf_out_id_code}")
print(f"hpf_out_id_code: {hpf_out_id_code}")
print(f"deriv_out_id_code: {deriv_out_id_code}")
print(f"squared_out_id_code: {squared_out_id_code}")
print(f"integral_out_id_code: {integral_out_id_code}")
print(f"peak_i_id_code: {peak_i_id_code}")
print(f"spu_id_code: {spu_id_code}")
print(f"regular_id_code: {regular_id_code}")

# -----------------------------------------------------------------------------
BIT_WIDTH = 16

counter = 0
for x in xin_values:
  xin_values[counter] = unsigned_to_signed(x, BIT_WIDTH)
  counter = counter + 1

counter = 0
for y in lpf_out_values:
  lpf_out_values[counter] = unsigned_to_signed(y, BIT_WIDTH)
  counter = counter + 1

counter = 0
for y in hpf_out_values:
  hpf_out_values[counter] = unsigned_to_signed(y, BIT_WIDTH)
  counter = counter + 1

counter = 0
for y in deriv_out_values:
  deriv_out_values[counter] = unsigned_to_signed(y, BIT_WIDTH)
  counter = counter + 1

# counter = 0
# for y in squared_out_values:
#   squared_out_values[counter] = unsigned_to_signed(y, BIT_WIDTH)
#   counter = counter + 1

# counter = 0
# for y in integral_out_values:
#   integral_out_values[counter] = unsigned_to_signed(y, BIT_WIDTH)
#   counter = counter + 1

counter = 0
for y in peak_i_values:
  peak_i_values[counter] = unsigned_to_signed(y, BIT_WIDTH)
  counter = counter + 1

counter = 0
for y in spu_values:
  spu_values[counter] = y * 3
  counter = counter + 1

counter = 0
for y in regular_values:
  regular_values[counter] = y * 3
  counter = counter + 1
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
x_min = 0
x_max = 0
for x in xin_values:
  if (x > x_max):
    x_max = x
  if (x < x_min):
    x_min = x

print("x_min: ", x_min)
print("x_max: ", x_max)

xin_values_norm = []
xin_values_fp = []

for x in xin_values:
  xin_values_norm.append(x / 100.0)
  xin_values_fp.append(x / 100 * 32)

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Convert signal values to integers if they are strings (e.g., "1", "0")
xin_signal_values = list(map(int, xin_values))
xin_signal_values_fp = list(map(int, xin_values_fp))
lpf_out_signal_values = list(map(int, lpf_out_values))
hpf_out_signal_values = list(map(int, hpf_out_values))
deriv_out_signal_values = list(map(int, deriv_out_values))
squared_out_signal_values = list(map(int, squared_out_values))
integral_out_signal_values = list(map(int, integral_out_values))
peak_i_signal_values = list(map(int, peak_i_values))
spu_signal_values = list(map(int, spu_values))
regular_signal_values = list(map(int, regular_values))

# Create the plot
rows = 7 # 9
cols = 1
plt.figure(figsize=(8, 12))

plt.subplot(rows, cols, 1)
plt.step(xin_timestamps, xin_signal_values, where='post', label='xin')
plt.step(spu_timestamps, spu_signal_values, where='post', label='QRS')
plt.ylabel('Xin', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

plt.subplot(rows, cols, 2)
plt.step(lpf_out_timestamps, lpf_out_signal_values, where='post', label='LPF')
plt.ylabel('LPF', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

plt.subplot(rows, cols, 3)
plt.step(hpf_out_timestamps, hpf_out_signal_values, where='post', label='HPF')
plt.ylabel('HPF', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

plt.subplot(rows, cols, 4)
plt.step(deriv_out_timestamps, deriv_out_signal_values, where='post', label='Derivative')
plt.ylabel('Deriv', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

plt.subplot(rows, cols, 5)
plt.step(squared_out_timestamps, squared_out_signal_values, where='post', label='Squared')
plt.ylabel('SQRD', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

plt.subplot(rows, cols, 6)
plt.step(integral_out_timestamps, integral_out_signal_values, where='post', label='Integration')
plt.step(spu_timestamps, spu_signal_values, where='post', label='QRS')
plt.ylabel('MWI', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

# plt.subplot(rows, cols, 7)
# plt.step(peak_i_timestamps, peak_i_signal_values, where='post', label='PEAKI')
# plt.ylabel('PEAKI', fontsize=12)
# plt.grid(True, linestyle='--', alpha=0.6)
# plt.legend(fontsize=12)

plt.subplot(rows, cols, 7)
plt.step(spu_timestamps, spu_signal_values, where='post', label='QRS')
plt.ylabel('QRS', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper right')

# plt.subplot(rows, cols, 9)
# plt.step(regular_timestamps, regular_signal_values, where='post', label='REGULAR')
# plt.ylabel('REGULAR', fontsize=12)
# plt.grid(True, linestyle='--', alpha=0.6)
# plt.legend(fontsize=12)

# Add labels, title, and legend
plt.xlabel('Time', fontsize=12)
# plt.ylabel('Signal Value', fontsize=12)
# plt.title('Signal Value Over Time', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12)

# Show the plot
plt.tight_layout()
plt.show()

#--------------------------------------
plt.figure(figsize=(10, 5))
plt.title('Pan Tompkins Algorithm', fontsize=14)

plt.step(xin_timestamps, xin_signal_values, where='post', label='xin')
plt.step(lpf_out_timestamps, lpf_out_signal_values, where='post', label='LPF')
plt.step(hpf_out_timestamps, hpf_out_signal_values, where='post', label='HPF')
plt.step(deriv_out_timestamps, deriv_out_signal_values, where='post', label='Derivative')
plt.step(squared_out_timestamps, squared_out_signal_values, where='post', label='Squared')
plt.step(integral_out_timestamps, integral_out_signal_values, where='post', label='Integration')
plt.step(spu_timestamps, spu_signal_values, where='post', label='QRS')
plt.step(regular_timestamps, regular_signal_values, where='post', label='REGULAR')

plt.xlabel('Time', fontsize=12)
plt.ylabel('Signal Values', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12)

# Show the plot
plt.tight_layout()
plt.show()
#--------------------------------------


#--------------------------------------
A = 1578000
B = 3000000
C = 1578000
D = 3000000

xin_timestamps_filtered = [xi for xi in xin_timestamps if A <= xi <= B]
xin_signal_values_filtered = [yi for xi, yi in zip(xin_timestamps, xin_signal_values) if A <= xi <= B]

lpf_out_timestamps_filtered = [xi for xi in lpf_out_timestamps if A <= xi <= B]
lpf_out_signal_values_filtered = [yi for xi, yi in zip(lpf_out_timestamps, lpf_out_signal_values) if A <= xi <= B]

hpf_out_timestamps_filtered = [xi for xi in hpf_out_timestamps if A <= xi <= B]
hpf_out_signal_values_filtered = [yi for xi, yi in zip(hpf_out_timestamps, hpf_out_signal_values) if A <= xi <= B]

deriv_out_timestamps_filtered = [xi for xi in deriv_out_timestamps if A <= xi <= B]
deriv_out_signal_values_filtered = [yi for xi, yi in zip(deriv_out_timestamps, deriv_out_signal_values) if A <= xi <= B]

squared_out_timestamps_filtered = [xi for xi in squared_out_timestamps if A <= xi <= B]
squared_out_signal_values_filtered = [yi for xi, yi in zip(squared_out_timestamps, squared_out_signal_values) if A <= xi <= B]

integral_out_timestamps_filtered = [xi for xi in integral_out_timestamps if A <= xi <= B]
integral_out_signal_values_filtered = [yi for xi, yi in zip(integral_out_timestamps, integral_out_signal_values) if A <= xi <= B]

spu_timestamps_filtered = [xi for xi in spu_timestamps if C <= xi <= D]
spu_signal_values_filtered = [yi for xi, yi in zip(spu_timestamps, spu_signal_values) if C <= xi <= D]

rows = 7
cols = 1
plt.figure(figsize=(8, 12))

plt.subplot(rows, cols, 1)
plt.step(xin_timestamps_filtered, xin_signal_values_filtered, where='post', label='xin')
plt.step(spu_timestamps_filtered, spu_signal_values_filtered, where='post', label='QRS')
plt.ylabel('Xin', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.subplot(rows, cols, 2)
plt.step(lpf_out_timestamps_filtered, lpf_out_signal_values_filtered, where='post', label='LPF')
plt.ylabel('LPF', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.subplot(rows, cols, 3)
plt.step(hpf_out_timestamps_filtered, hpf_out_signal_values_filtered, where='post', label='HPF')
plt.ylabel('HPF', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.subplot(rows, cols, 4)
plt.step(deriv_out_timestamps_filtered, deriv_out_signal_values_filtered, where='post', label='Derivative')
plt.ylabel('Deriv', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.subplot(rows, cols, 5)
plt.step(squared_out_timestamps_filtered, squared_out_signal_values_filtered, where='post', label='Squared')
plt.ylabel('SQRD', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.subplot(rows, cols, 6)
plt.step(integral_out_timestamps_filtered, integral_out_signal_values_filtered, where='post', label='Integration')
plt.step(spu_timestamps_filtered, spu_signal_values_filtered, where='post', label='QRS')
plt.ylabel('MWI', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.subplot(rows, cols, 7)
plt.step(spu_timestamps_filtered, spu_signal_values_filtered, where='post', label='QRS')
plt.ylabel('QRS', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12, loc='upper left')

plt.xlabel('Time', fontsize=12)
# plt.ylabel('Signal Values', fontsize=12)
# plt.title('Signal Value Over Time', fontsize=14)
# plt.grid(True, linestyle='--', alpha=0.6)
# plt.legend(fontsize=12)

# Show the plot
plt.tight_layout()
plt.show()
#--------------------------------------


#--------------------------------------
plt.figure(figsize=(8, 12))
plt.title('Pan Tompkins Algorithm', fontsize=14)

plt.step(xin_timestamps_filtered, xin_signal_values_filtered, where='post', label='xin')
plt.step(lpf_out_timestamps_filtered, lpf_out_signal_values_filtered, where='post', label='LPF')
plt.step(hpf_out_timestamps_filtered, hpf_out_signal_values_filtered, where='post', label='HPF')
plt.step(deriv_out_timestamps_filtered, deriv_out_signal_values_filtered, where='post', label='Derivative')
plt.step(squared_out_timestamps_filtered, squared_out_signal_values_filtered, where='post', label='Squared')
plt.step(integral_out_timestamps_filtered, integral_out_signal_values_filtered, where='post', label='Integration')
plt.step(spu_timestamps_filtered, spu_signal_values_filtered, where='post', label='QRS')

plt.xlabel('Time', fontsize=12)
plt.ylabel('Signal Values', fontsize=12)
# plt.title('Signal Value Over Time', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=12)

# Show the plot
plt.tight_layout()
plt.show()
#--------------------------------------
