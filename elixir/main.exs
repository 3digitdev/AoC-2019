defmodule Inputs do
    def readMultiLine(day) do
        case File.read("../inputs/#{day}.txt") do
            {:ok, body} ->
                {:ok, String.split(body)}
            {:error, reason} ->
                {:error, reason}
        end
    end

    def readCommaSep(day) do
        case File.read("../inputs/#{day}.txt") do
            {:ok, body} ->
                {:ok, body |> String.trim |> String.split(",")}
            {:error, reason} ->
                {:error, reason}
        end
    end
end


defmodule DayOne do
    def run() do
        IO.puts("Day 1:")
        case Inputs.readMultiLine("day1") do
            {:ok, lines} ->
                result = List.foldl(lines, 0, fn x, acc ->
                    acc + (x |> String.to_integer |> calcFuel |> fuelUntilZero)
                end)
                IO.puts("  #{result}")
            {:error, reason} ->
                IO.puts(reason)
        end
    end

    defp calcFuel(mass) do
        Integer.floor_div(mass, 3) - 2
    end

    defp fuelUntilZero(next, total \\ 0) do
        if next <= 0 do
            total
        else
            fuelUntilZero(calcFuel(next), total + next)
        end
    end
end

defmodule DayTwo do
    def run() do
        IO.puts("Day 2:")
        IO.puts("  Part 1: #{partOne()}")
        IO.puts("  Part 2: #{partTwo()}")
    end

    defp partOne() do
        case Inputs.readCommaSep("day2") do
            {:ok, program} ->
                program |> executeIntcode(12, 2)
            {:error, reason} ->
                IO.puts(reason)
        end
    end

    defp partTwo() do
        case Inputs.readCommaSep("day2") do
            {:ok, program} ->
                for noun <- Enum.to_list(0..99), verb <- Enum.to_list(0..99) do
                    if program |> executeIntcode(noun, verb) == 19690720 do
                        100 * noun + verb
                    else
                        0
                    end
                end |> Enum.reject(fn x -> x == 0 end) |> List.first
            {:error, reason} ->
                reason
        end
    end

    defp executeIntcode(inputs, noun, verb) do
        insts = Enum.map(inputs, fn x -> String.to_integer(x) end)
            |> List.update_at(1, fn _ -> noun end)
            |> List.update_at(2, fn _ -> verb end)
        codes = Range.new(0, length(insts))
            |> Enum.reject(fn x -> Integer.mod(x, 4) > 0 end)
            |> Enum.map(fn x -> {x, Enum.at(insts, x)} end)
        final = codes |> Enum.reduce(insts, fn x, acc ->
            {i, code} = x
            case code do
                1 ->
                    List.update_at(acc, Enum.at(acc, i+3), fn _ -> Enum.at(acc, Enum.at(acc, i+1)) + Enum.at(acc, Enum.at(acc, i+2)) end)
                2 ->
                    List.update_at(acc, Enum.at(acc, i+3), fn _ -> Enum.at(acc, Enum.at(acc, i+1)) * Enum.at(acc, Enum.at(acc, i+2)) end)
                _ -> acc
            end
        end)
        List.first(final)
    end
end

DayOne.run()
DayTwo.run()
