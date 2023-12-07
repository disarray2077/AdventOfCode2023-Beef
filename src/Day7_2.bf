using System;
using System.IO;
using System.Linq;
using System.Collections;
using System.Diagnostics;

namespace AoC;

class Program
{
	struct Hand : this(StringView cards, int bid)
	{
		const String[?] labels = .("J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A");
		enum Kind { High, One, Two, Three, Full, Four, Five }

		const int HandSize = 5;

		public Kind Kind
		{
			get
			{
				int[labels.Count] counts = .();
				for (int i < HandSize)
					counts[labels.IndexOf(cards[i].ToString())] += 1;

				// Joker's special case.
				if (counts[0] > 0)
				{
					int maxIndex = 1;
					for (int i = 1; i < counts.Count; i++)
					{
						if (counts[i] > counts[maxIndex])
							maxIndex = i;
					}
					if (maxIndex != 0)
					{
						counts[maxIndex] += counts[0];
						counts[0] = 0;
					}
				}

				if (counts.Contains(5))
					return .Five;
				if (counts.Contains(4) && counts.Contains(1))
					return .Four;
				if (counts.Contains(3) && counts.Contains(2))
					return .Full;
				if (counts.Contains(3) && counts.Count(1) == 2)
					return .Three;
				if (counts.Count(2) == 2 && counts.Contains(1))
					return .Two;
				if (counts.Contains(2) && counts.Count(1) == 3)
					return .One;
				if (counts.Count(1) == 5)
					return .High;
				Runtime.NotImplemented();
			}
		}

		public static int operator <=>(Hand lhs, Hand rhs)
		{
			if (lhs.Kind != rhs.Kind)
				return (int)lhs.Kind <=> (int)rhs.Kind;
			for (int i < HandSize)
			{
				int lhsScore = labels.IndexOf(lhs.cards[i].ToString());
				int rhsScore = labels.IndexOf(rhs.cards[i].ToString());
				if (lhsScore == rhsScore)
					continue;
				return lhsScore <=> rhsScore;
			}
			return 0;
		}
	}

	public static Result<void> ParseHands(StringView text, List<Hand> hands)
	{
		for (var line in text.Split('\n'))
		{
			line.Trim();
			var splitter = line.Split(' ');
			hands.Add(Hand(Try!(splitter.GetNext()), int.Parse(Try!(splitter.GetNext()))));
		}
		return .Ok;
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day7.txt");
		let text = scope StreamReader(fs).ReadToEnd(.. scope .())..Replace("\r\n", "\n");

		List<Hand> hands = scope .();
		ParseHands(text, hands);
		hands.Sort();

		int totalWinnings = hands.Select((h, i) => (bid: h.bid, rank: i+1)).Sum((h) => h.rank * h.bid);
		Console.WriteLine(totalWinnings);
		Console.Read();
	}
}