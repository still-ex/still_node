defmodule Still.Node.Process do
  use GenServer

  @js_server Application.app_dir(:still_node, "priv/server.js")
  @node_env if Mix.env() == :prod, do: 'production', else: 'development'
  @prefix '__elixirnodejs__UOSBsDUP6bp9IF5__'
  @read_chunk_size 65_536
  @default_name "process"

  require Logger

  def start_link(args) do
    name = Keyword.get(args, :name, @default_name)

    GenServer.start_link(__MODULE__, args, name: process_name(name))
  end

  def invoke(fun, args, opts \\ []) do
    invoke(@default_name, fun, args, opts)
  end

  def invoke(name, fun, args, opts) do
    process_name(name)
    |> GenServer.call({:invoke, fun, args, opts}, :infinity)
  end

  def init(args) do
    file= Keyword.fetch!(args, :file)
    node = System.find_executable("node")

    port =
      Port.open(
        {:spawn_executable, node},
        line: @read_chunk_size,
        env: [
          {'NODE_ENV', @node_env},
          {'WRITE_CHUNK_SIZE', String.to_charlist("#{@read_chunk_size}")}
        ],
        args: [@js_server, file]
      )

    {:ok, %{port: port, responses: %{}}, {:continue, :start}}
  end

  def handle_continue(:start, state) do
    {:noreply, state}
  end

  def handle_call({:invoke, fun, args, opts}, _pid, state) do
    body = Jason.encode!([fun, args])
    timeout = Keyword.get(opts, :timeout, 5000)

    Port.command(state.port, "#{body}\n")

    case get_response('', timeout) do
      {:ok, response} ->
        decoded_response =
          response
          |> decode()

        {:reply, decoded_response, state}

      {:error, :timeout} ->
        {:reply, {:error, :timeout}, state}
    end
  end

  def handle_info({_, {:data, {_, message}}}, state) do
    if message != [] do
      Logger.debug(message)
    end

    {:noreply, state}
  end

  defp get_response(data, timeout) do
    receive do
      {_, {:data, {flag, chunk}}} ->
        data = data ++ chunk

        case flag do
          :noeol ->
            get_response(data, timeout)

          :eol ->
            case data do
              @prefix ++ protocol_data ->
                {:ok, protocol_data}

              [] ->
                get_response('', timeout)

              message ->
                Logger.debug(message)
                get_response('', timeout)
            end
        end
    after
      timeout ->
        {:error, :timeout}
    end
  end

  defp decode(data) do
    data
    |> to_string()
    |> Jason.decode!()
    |> case do
      [true, success] -> {:ok, success}
      [false, error] -> {:error, error}
    end
  end

  def terminate(reason, state) do
    Logger.error(reason)
    send(state.port, {self(), :close})
  end

  def process_name(name) do
    String.to_atom("still_node_worker_#{name}")
  end
end
