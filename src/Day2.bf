using System;
using System.IO;
using System.Linq;
using System.Collections;

namespace AoC;

class Program
{
	class Game
	{
		struct Set
		{
			public int redCount;
			public int blueCount;
			public int greenCount;

			public static Result<Set> Parse(StringView text)
			{
				Set set = .();
				for (var cubeText in text.Split(','))
				{
					cubeText.Trim();
					var splitter = cubeText.Split(' ');
					let count = Try!(int.Parse(Try!(splitter.GetNext())));
					let color = Try!(splitter.GetNext());
					switch (color)
					{
					case "red":
						set.redCount += count;
					case "green":
						set.greenCount += count;
					case "blue":
						set.blueCount += count;
					default:
						return .Err;
					}
				}
				return .Ok(set);
			}
		}

		public int id;
		public List<Set> sets = new .() ~ delete _;

		public Result<void> Parse(StringView text)
		{
			var splitter = text.Split(": ");
			this.id = int.Parse(Try!(splitter.GetNext()).Split(' ').ElementAt(1));
			for (var setText in Try!(splitter.GetNext()).Split(';'))
				sets.Add(Try!(Set.Parse(setText..Trim())));
			return .Ok;
		}
	}

	public static bool IsGamePossible(Game game)
	{
		return !game.sets.Any((s) => s.redCount > 12 || s.greenCount > 13 || s.blueCount > 14);
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day2.txt");
		let ss = scope StreamReader(fs);

		List<Game> games = scope .();
		while (!ss.EndOfStream)
		{
			let line = (Span<char8>)ss.ReadLine(.. scope .());
			games.Add(scope:: Game()..Parse(line));
		}

		int sum = games.Where(=> IsGamePossible).Sum((g) => g.id);
		Console.WriteLine(sum);
		Console.Read();
	}
}