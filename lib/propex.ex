defmodule PropEx do
  @moduledoc """
  A wrapper around PropEr
  """

  alias Code.Typespec

  def convert_typespec(_type), do: :proper_types.integer()

  def convert_argument_spec({:"::", _, [{name, _, nil}, type]}), do:
    {name, convert_typespec(type)}
  def convert_argument_spec({:"::", _, [name, type]}) when is_atom(name), do:
    {name, convert_typespec(type)}
  def convert_argument_spec(_spec), do:
    raise ArgumentError, """
    PropEx: Your type specification seems to be missing variable names.
    When using arguments_of, instead of:

        @spec add(integer(), integer()) :: integer()
        def add(a, b), do: a + b

    You should write:

        @spec add(a :: integer(), b :: integer()) :: integer()
        def add(a, b), do: a + b
    """

  def convert_argument_list(argument_list) do
    argument_list
      |> Enum.map(&convert_argument_spec/1)
      |> Enum.into(%{})
      |> Map.values
      |> :erlang.list_to_tuple
  end

  def get_arguments_of({:/, _, [call, arity]}, context) do
    # parse the function reference
    {orig_mod, mod, fun, arity} = case Macro.decompose_call(call) do
      {mod, fun, []} -> {mod, Macro.expand(mod, context), fun, arity}
      _ -> get_arguments_of(:yolo, context) # to raise an error
    end

    # fetch function specification and extract the arguments from it
    args = with {:ok, specs} <- Typespec.fetch_specs(mod),
         {{^fun, ^arity}, [spec]} <- List.keyfind(specs, {fun, arity}, 0),
         {:"::", _, [{^fun, _, args}, _return_type]} <- Typespec.spec_to_quoted(fun, spec) do
      args
    else
      error -> raise ArgumentError, "PropEx: unable to access the @spec for function #{mod}.#{fun}/#{arity}: #{error}"
    end

    # generate the AST for `arg1, arg2, ...`
    call_args = args
      |> Enum.map(fn
        {:"::", _, [{name, _, nil}, _type]} -> name
        {:"::", _, [name, _type]} -> name
      end)
      |> Enum.map(fn var_name -> {:var!, [], [{var_name, [], __MODULE__}]} end)

    # generate the AST for `result = mod.fun(args)`
    result_fetcher = {:=, [], [{:var!, [], [{:result, [], __MODULE__}]}, {{:., [], [orig_mod, fun]}, [], call_args}]}

    {args, result_fetcher}
  end

  def get_arguments_of(_, _), do: raise ArgumentError, """
    PropEx: It looks like you passed something other than Mod.fun/arity to arguments_of. You should use it like this:

        forall arguments_of MyModule.my_fun/2 do
          # code
        end
    """

  defmacro __using__(_env) do
    quote do
      require PropEx
      import PropEx, only: [forall: 2]
    end
  end

  defmacro forall(argument_list, opts) do
    # if argument_list is actually a request to fetch the arguments from the
    # specs, do that
    {argument_list, result_fetcher} = case argument_list do
      {:arguments_of, _, [ast_fun_ref]} -> get_arguments_of(ast_fun_ref, __CALLER__)
      _ -> {argument_list, nil}
    end

    # process argument list
    destructurer = argument_list
      |> Enum.map(&convert_argument_spec/1)
      |> Enum.into(%{})
      |> Map.keys
      |> Enum.map(fn var_name -> {:var!, [], [{var_name, [], __MODULE__}]} end)
      |> :erlang.list_to_tuple

    quote do
      assert :proper.forall(PropEx.convert_argument_list(unquote(Macro.escape(argument_list))), fn arguments ->
        unquote(destructurer) = arguments
        unquote(result_fetcher)
        unquote(opts[:do])
      end) |> :proper.quickcheck
    end
  end
end
