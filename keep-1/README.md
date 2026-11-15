# Keep-1

A small chip that reads handwritten digits (0 to 9). It looks at an 8x8 black-and-white picture and says which digit it is. I made it to learn how a chip goes from an idea to a real layout.

**Status: a learning project. Not manufactured.**

## Results

| What | Result |
|---|---|
| Test digits | 540 (never used for training) |
| Chip vs. Python model | same answer on all 540 |
| Accuracy | 491 / 540 = 90.9 % |
| Time per digit | 652 clock ticks |
| Size | 772 gates, about 7,500 transistors (a rough estimate) |
| Layout | about 130 x 140 um, DRC and LVS passed |

**Timing:** at a 10 ns clock the chip is fast enough in normal conditions, but in the slowest condition (hot, low voltage) it fails by 2.6 ns. I think about 13 ns would fix it, but I have not checked.

**This is not real MNIST.** It uses the small 8x8 digits set from scikit-learn, so do not compare the accuracy with MNIST results.

## How it works

Each of the ten neurons has 64 small weights, one for every pixel. It adds up the weights of the pixels that are on, and the neuron with the biggest score is the answer. The chip has just one adder, so it does one pixel per clock tick.

## Files

```
paper/     the write-up (PDF and LaTeX)
rtl/       digitnet.v      the chip in Verilog
test/      tb_full.sv      testbench with 540 test images
scripts/   train_quantize.py   trains the model and shrinks it to 3 bits
layout/    digitnet.gds    the final layout, plus pictures
```

The chip is called Keep-1, but the Verilog module and files are still named `digitnet`, because a name with a hyphen is not allowed in Verilog.

## Run it

Simulate the chip (needs [Icarus Verilog](https://steveicarus.github.io/iverilog/)):

```
iverilog -g2012 -o sim rtl/digitnet.v test/tb_full.sv
vvp sim
```

You should see `PASS: hardware matches the trained model exactly`.

Train the model (needs Python with numpy and scikit-learn):

```
python scripts/train_quantize.py
```

Look at the layout: open `layout/digitnet.gds` in [KLayout](https://www.klayout.de/).

## Notes

Made by Garv Agnihotri. The layout uses cells from the [SkyWater SKY130 PDK](https://github.com/google/skywater-pdk).
