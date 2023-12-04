using System;
using System.IO;
using System.Linq;

namespace AoC;

class Program
{
	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day1.txt");
		let ss = scope StreamReader(fs);

		var sum = 0;
		while (!ss.EndOfStream)
		{
			let line = (Span<char8>)ss.ReadLine(.. scope .());
			let firstDigit = line.First((c) => c.IsDigit);
			let lastDigit = line.Last((c) => c.IsDigit);
			sum += int.Parse(scope $"{firstDigit}{lastDigit}");
		}

		Console.WriteLine(sum);
		Console.Read();
	}
}