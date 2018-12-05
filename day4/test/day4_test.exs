defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  test "parse_records" do
    records = [
      "[1518-11-01 00:00] Guard #10 begins shift",
      "[1518-11-01 00:05] falls asleep",
      "[1518-11-01 00:25] wakes up",
      "[1518-11-01 00:30] falls asleep",
      "[1518-11-01 00:55] wakes up",
      "[1518-11-01 23:58] Guard #99 begins shift",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-02 00:50] wakes up",
      "[1518-11-03 00:05] Guard #10 begins shift",
      "[1518-11-03 00:24] falls asleep",
      "[1518-11-03 00:29] wakes up",
      "[1518-11-04 00:02] Guard #99 begins shift",
      "[1518-11-04 00:36] falls asleep",
      "[1518-11-04 00:46] wakes up",
      "[1518-11-05 00:03] Guard #99 begins shift",
      "[1518-11-05 00:45] falls asleep",
      "[1518-11-05 00:55] wakes up"
    ]

    assert Day4.parse_records(records) == %{
             10 => %{
               5 => 1,
               6 => 1,
               7 => 1,
               8 => 1,
               9 => 1,
               10 => 1,
               11 => 1,
               12 => 1,
               13 => 1,
               14 => 1,
               15 => 1,
               16 => 1,
               17 => 1,
               18 => 1,
               19 => 1,
               20 => 1,
               21 => 1,
               22 => 1,
               23 => 1,
               24 => 2,
               25 => 1,
               26 => 1,
               27 => 1,
               28 => 1,
               30 => 1,
               31 => 1,
               32 => 1,
               33 => 1,
               34 => 1,
               35 => 1,
               36 => 1,
               37 => 1,
               38 => 1,
               39 => 1,
               40 => 1,
               41 => 1,
               42 => 1,
               43 => 1,
               44 => 1,
               45 => 1,
               46 => 1,
               47 => 1,
               48 => 1,
               49 => 1,
               50 => 1,
               51 => 1,
               52 => 1,
               53 => 1,
               54 => 1
             },
             99 => %{
               36 => 1,
               37 => 1,
               38 => 1,
               39 => 1,
               40 => 2,
               41 => 2,
               42 => 2,
               43 => 2,
               44 => 2,
               45 => 3,
               46 => 2,
               47 => 2,
               48 => 2,
               49 => 2,
               50 => 1,
               51 => 1,
               52 => 1,
               53 => 1,
               54 => 1
             }
           }
  end

  test "compile_records" do
    assert Day4.compile_records([
             {:guard, 2},
             {:sleep, 14},
             {:wake, 32},
             {:sleep, 44},
             {:wake, 51}
           ]) == %{2 => [{:sleep, 14}, {:wake, 32}, {:sleep, 44}, {:wake, 51}]}

    assert Day4.compile_records([
             {:guard, 2},
             {:sleep, 14},
             {:wake, 32},
             {:guard, 3},
             {:sleep, 44},
             {:wake, 51}
           ]) == %{
             2 => [{:sleep, 14}, {:wake, 32}],
             3 => [{:sleep, 44}, {:wake, 51}]
           }
  end

  test "records_to_time_counts" do
    assert Day4.records_to_time_counts([
             {:sleep, 12},
             {:wake, 14}
           ]) == %{
             12 => 1,
             13 => 1
           }

    assert Day4.records_to_time_counts([
             {:sleep, 12},
             {:wake, 14},
             {:sleep, 24},
             {:wake, 31}
           ]) == %{
             12 => 1,
             13 => 1,
             24 => 1,
             25 => 1,
             26 => 1,
             27 => 1,
             28 => 1,
             29 => 1,
             30 => 1
           }

    assert Day4.records_to_time_counts([
             {:sleep, 12},
             {:wake, 16},
             {:sleep, 14},
             {:wake, 18}
           ]) == %{
             12 => 1,
             13 => 1,
             14 => 2,
             15 => 2,
             16 => 1,
             17 => 1
           }
  end

  test "guard_with_most_sleep" do
    assert Day4.guard_with_most_sleep(%{
             1 => %{
               1 => 1,
               2 => 1,
               3 => 1,
               4 => 1,
               5 => 1,
               6 => 1
             }
           }) == 1

    assert Day4.guard_with_most_sleep(%{
             1 => %{
               1 => 1,
               2 => 1,
               3 => 1,
               4 => 1,
               5 => 1,
               6 => 1
             },
             2 => %{
               1 => 1,
               2 => 3,
               5 => 2,
               6 => 1
             }
           }) == 2
  end
end
