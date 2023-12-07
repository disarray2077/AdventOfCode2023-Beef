using System;
using System.IO;
using System.Linq;
using System.Collections;

namespace AoC;

class Program
{
	struct Race : this(int time, int distance);

	public static Result<void> ParseRaces(StringView text, List<Race> races)
	{
		var lines = text.Split('\n');
		var timeText = Try!(lines.GetNext()).Split(' ', .RemoveEmptyEntries).Skip(1).Aggregate(scope:: String(), (x, y) => x..Append(y));
		var distanceText = Try!(lines.GetNext()).Split(' ', .RemoveEmptyEntries).Skip(1).Aggregate(scope:: String(), (x, y) => x..Append(y));
		races.Add(Race(int.Parse(timeText), int.Parse(distanceText)));
		return .Ok;
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day6.txt");
		let text = scope StreamReader(fs).ReadToEnd(.. scope .())..Replace("\r\n", "\n");

		List<Race> races = scope .();
		ParseRaces(text, races);

		int result = 1;
		for (let race in races)
		{
			int ways = 0;
			for (int i < race.time)
			{
				if (i * (race.time - i) > race.distance)
					ways += 1;
			}
			result *= ways;
		}

		Console.WriteLine(result);
		Console.Read();
	}
}