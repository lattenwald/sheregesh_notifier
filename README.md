# Sheregesh weather notifier

## Usage

Currently runs at [@shrgshbot](https://telegram.me/shrgshbot)

## Installation

To run it yourself you should have [elixir](http://elixir-lang.org/) installed. Clone this repo and

    $ nano apps/notifier/config/config.exs
    $ mix deps.get
    $ mix run --no-halt

I use [distillery](https://hex.pm/packages/distillery) and [edeliver](https://hex.pm/packages/edeliver) for building releases and deploying. You are free to fork and modify delivery configuration at `.deliver/config`.
