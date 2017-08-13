# AVR Rust Docker

A docker container to build the AVR Rust toolchain found [here](https://github.com/avr-rust/rust/tree/avr-support). The demo project supports Arduino Unos with the ATmega328p microcontroller.

## Build

### Checkout this repo

```sh
$ git clone https://github.com/code0100fun/avr-rust-docker.git
```

### Build the image

This takes a **LONG** time (~2hrs)!

```sh
$ cd avr-rust-docker
$ docker build -t avr-rust .
$ cd ../
```

### Make a new project

This checks out a [fork](https://github.com/code0100fun/avr-rust-project/tree/project) of [shepmaster/rust-arduino-blink-led-no-core-with-cargo](https://github.com/shepmaster/rust-arduino-blink-led-no-core-with-cargo/tree/wild-changes) that is configured with the name you provide.

```sh
$ docker run --rm -v $(pwd):/usr/src/app avr-rust new blink
creating new project named  blink
Cloning into '/usr/src/app/blink'...
Initialized empty Git repository in /usr/src/app/blink/.git/
[master (root-commit) 2a9f04c] Initial Commit
 9 files changed, 402 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 Cargo.lock
 create mode 100644 Cargo.toml
 create mode 100644 Makefile
 create mode 100644 README.md
 create mode 100644 arduino.json
 create mode 100644 initialize_memory.S
 create mode 100644 interrupt_vector.S
 create mode 100644 src/main.rs
```

### Build the project

This builds the project with the `rustc` from the avr-rust crosscompiler. The output object is then converted to AVR \*.hex file format.

```sh
$ cd blink
$ docker run --rm -v $(pwd):/usr/src/app avr-rust build
cargo build --release --target=./arduino.json
    Updating git repository `https://github.com/gergoerdi/rust-avr-libcore-mini`
    Updating git repository `https://github.com/code0100fun/arduino`
    Finished release [optimized] target(s) in 0.0 secs
avr-objcopy -O ihex -R .eeprom target/arduino/release/blink.elf blink.hex
```

### Burn to Arduino

Send the \*.hex file to the Arduino over USB serial using `avrdude`.

```$
$ avrdude -p atmega328p -c arduino -P /dev/<device> -U flash:w:blink.hex:i
```

or use the `Makefile` step.

```sh
$ make program
```

## Attribution

Based entirly off the work of Jake Goulding ([@JakeGoulding](https://twitter.com/JakeGoulding), [shepmaster](https://github.com/shepmaster)). Check out his blog series about ["Rust on an Arduino Uno"](http://jakegoulding.com/blog/2016/01/02/rust-on-an-arduino-uno/).

Also would not be possible without the LLVM AVR backend built by a large number of [contributers](https://github.com/avr-llvm/llvm/graphs/contributors) that has now been merged into [LLVM](https://github.com/llvm-mirror/llvm/tree/13a58815239cfab76c77444db174c1209f0ad075/lib/Target/AVR).

Thanks for all the hard work bringing Rust to AVR!
