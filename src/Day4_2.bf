using System;
using System.IO;
using System.Linq;
using System.Collections;

namespace AoC;

class Program
{
	class CardPile
	{
		public List<int> winningNumbers = new .() ~ delete _;
		public List<int> numbers = new .() ~ delete _;
		public int score = 1;

		public static Result<CardPile> Parse(StringView text)
		{
			CardPile cardPile = new .();

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

		public int WinCount
		{
			get
			{
				int winCount = 0;
				for (let number in numbers)
				{
					if (winningNumbers.Contains(number))
						winCount += 1;
				}
				return winCount;
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
			cards.Add(CardPile.Parse(line.Split(": ").ElementAt(1)));
		}

		int sum = 0;
		for (int i < cards.Count)
		{
			let card = cards[i];
			for (int j < card.WinCount)
			{
				var otherCard = ref cards[i + j + 1];
				otherCard.score += card.score;
			}
			sum += card.score;
		}

		Console.WriteLine(sum);
		ClearAndDeleteItems!(cards);
		Console.Read();
	}
}