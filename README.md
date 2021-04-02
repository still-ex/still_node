# Still.Node

An Elixir library to manage long-running NodeJS processes.

## Documentation

The goal of `Still.Node` is to simplify the integration of NodeJS processes in
Elixir apps. It was originally built for [Still](http://stillstatic.io/) to run a dev
server like Snowpack, Webpack, and others.

The difference to [revelrylabs/elixir-nodejs](https://github.com/revelrylabs/elixir-nodejs)
is that `Still.Node` can handle stateful processes, while elixir-nodejs
works better when the functions you want to call are pure or stateless.
You'll find that we copied a lot of code from elixir-nodejs, but
the differences between the two projects are too big to contribute
code back.

Check the tests for usage examples.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `still_node` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:still_node, "~> 0.1.0"}
  ]
end
```
