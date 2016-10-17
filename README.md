# Teller

```
iex> BankQueue.start
```

```
iex> for _n <- 1..10, do: BankQueue.start_tellers
```

```
iex> BankQueue.push 1..1000
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add teller to your list of dependencies in `mix.exs`:

        def deps do
          [{:teller, "~> 0.0.1"}]
        end

  2. Ensure teller is started before your application:

        def application do
          [applications: [:teller]]
        end

