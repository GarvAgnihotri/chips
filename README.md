# Chips

My chip designs. I make them to learn how chips are built, using free open-source tools.

## My chips

| Folder | What it does | Status |
|---|---|---|
| [keep-1](keep-1/) | Reads handwritten digits (0 to 9) from an 8x8 picture | Layout done, not manufactured |

More chips will be added here. Each chip has its own folder with its own README.

## What is in a chip folder

```
rtl/       the chip in Verilog
test/      the testbench
layout/    the final layout and pictures
README.md  what it is and how to run it
```

## Tools I use

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) to simulate
- [Yosys](https://github.com/YosysHQ/yosys) to turn Verilog into gates
- [LibreLane](https://github.com/librelane/librelane) to make the layout (SkyWater SKY130 process)
- [KLayout](https://www.klayout.de/) to look at the layout

## About

Made by Garv Agnihotri. These are learning projects.
