using System;
using System.IO;
using System.Linq;
using System.Collections;

namespace AoC;

class Program
{
	public static int CountDigits(int i)
	{
		var i;
	    var n = 1;
	    while (i > 9)
		{
	        n++;
	        i /= 10;
	    }
	    return n;
	}

	struct Vector2 : this(int x, int y), IHashable
	{
		public int GetHashCode()
		{
			return x | (y << 15);
		}
	}

	struct Symbol : this(Vector2 position, char8 type);
	struct PartNumber : this(Vector2 position, int number)
	{
		public int Width => CountDigits(number);

		public bool IsAdjacentTo(Vector2 symbolPos)
		{
			return (symbolPos.x >= position.x - 1 && symbolPos.x <= position.x + Width) &&
				(symbolPos.y >= position.y - 1 && symbolPos.y <= position.y + 1);
		}
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day3.txt");
		let ss = scope StreamReader(fs);

		List<PartNumber> numbers = scope .();
		List<Symbol> symbols = scope .();
		Dictionary<Vector2, List<PartNumber>> gears = scope .();

		int y = 0;
		while (!ss.EndOfStream)
		{
			let line = (StringView)ss.ReadLine(.. scope .());
			int x = 0;
			while (x < line.Length)
			{
				if (line[x].IsDigit)
				{
					let lineSub = line.Substring(x);
					switch (int.Parse(lineSub))
					{
					case .Ok(let val):
						numbers.Add(.(.(x, y), val));
						x += CountDigits(val);
					case .Err(let err):
						switch (err)
						{
						case .InvalidChar(let partialResult):
							numbers.Add(.(.(x, y), partialResult));
							x += CountDigits(partialResult);
							break;
						default:
							Runtime.FatalError();
						}
					}
				}
				else
				{
					if (line[x] != '.')
						symbols.Add(.(.(x, y), line[x]));
					x += 1;
				}
			}
			y += 1;
		}

		for (let number in numbers)
		{
			for (let symbol in symbols.Where((symbol) => symbol.type == '*'))
			{
				List<PartNumber> gearList = null;
				if (gears.TryAdd(symbol.position, let keyPtr, let valuePtr))
					*valuePtr = gearList = scope:: List<PartNumber>();
				else
					gearList = *valuePtr;

				if (number.IsAdjacentTo(symbol.position))
					gearList.Add(number);
			}
		}

		int sum = gears.Values.Where((g) => g.Count == 2).Select((g) => g[0].number * g[1].number).Sum();
		Console.WriteLine(sum);
		Console.Read();
	}
}