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

	struct Vector2 : this(int x, int y);
	struct Symbol : this(Vector2 position);
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
						symbols.Add(.(.(x, y)));
					x += 1;
				}
			}
			y += 1;
		}

		int sum = numbers.Where((number) => symbols.Any((symbol) => number.IsAdjacentTo(symbol.position))).Sum((n) => n.number);
		Console.WriteLine(sum);
		Console.Read();
	}
}