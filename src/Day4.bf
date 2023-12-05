using System;
using System.IO;
using System.Linq;
using System.Collections;

namespace AoC;

class Program
{
	struct CardPile
	{
		List<int> winningNumbers;
		List<int> numbers;

		public static Result<CardPile> Parse(StringView text)
		{
			CardPile cardPile = .();
			cardPile.winningNumbers = new .();
			cardPile.numbers = new .();
			var splitter = text.Split('|');
			for (let winningNumber in Try!(splitter.GetNext()).Split(' ', .RemoveEmptyEntries))
			{
				cardPile.winningNumbers.Add(int.Parse(winningNumber));
			}
			for (let number in Try!(splitter.GetNext()).Split(' ', .RemoveEmptyEntries))
			{
				cardPile.numbers.Add(int.Parse(number));
			}
			return .Ok(cardPile);
		}

		public int Score
		{
			get
			{
				int matchCount = 0;
				for (let number in numbers)
				{
					if (winningNumbers.Contains(number))
						matchCount += 1;
				}
				return matchCount <= 2 ? matchCount : 1 << (matchCount - 1);
			}
		}
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day4.txt");
		let ss = scope StreamReader(fs);

		List<CardPile> cards = scope .();
		while (!ss.EndOfStream)
		{
			let line = (StringView)ss.ReadLine(.. scope .());
			var splitter = line.Split(": ");
			let identifier = splitter.GetNext();
			let info = splitter.GetNext();
			cards.Add(CardPile.Parse(info));
		}

		int sum = cards.Sum((c) => c.Score);
		Console.WriteLine(sum);
		Console.Read();
	}
}