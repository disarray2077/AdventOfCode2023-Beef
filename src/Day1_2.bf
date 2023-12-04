using System;
using System.IO;
using System.Linq;
using System.Collections;

namespace AoC;

class Program
{
	struct NumberEnumerator : IEnumerator<int>
	{
		public StringView text;
		public int offset;
		public bool reversed;

		public this(StringView text, bool reversed = false)
		{
			this.text = text;
			this.offset = reversed ? text.Length - 1 : 0;
			this.reversed = reversed;
		}

		public bool HasMore
		{
			get => this.reversed ? offset >= 0 : offset < text.Length;
		}

		private void Adjust(int ofs) mut
		{
			if (this.reversed)
				this.offset -= ofs;
			else
				this.offset += ofs;
		}

		public Result<int> GetNext() mut
		{
			const (StringView, int)[?] spelledDigits = .(
				("zero", 0),
				("one", 1),
				("two", 2),
				("three", 3),
				("four", 4),
				("five", 5),
				("six", 6),
				("seven", 7),
				("eight", 8),
				("nine", 9)
			);

			while (HasMore)
			{
				if (text[offset].IsDigit)
				{
					let digit = int.Parse(text.Substring(offset, 1));
					Adjust(1);
					return .Ok(digit);
				}
				else
				{
					for (let (spelledDigit, digit) in spelledDigits)
					{
						if (text.Length - offset < spelledDigit.Length)
							continue;
						let text = text.Substring(offset, spelledDigit.Length);
						if (StringView.Compare(text, spelledDigit, true) == 0)
						{
							Adjust(spelledDigit.Length);
							return .Ok(digit);
						}
					}
				}
				Adjust(1);
			}
			return .Err;
		}
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day1.txt");
		let ss = scope StreamReader(fs);

		var sum = 0;
		while (!ss.EndOfStream)
		{
			let line = (Span<char8>)ss.ReadLine(.. scope .());
			let firstDigit = NumberEnumerator(line).First();
			let lastDigit = NumberEnumerator(line, true).First();
			sum += int.Parse(scope $"{firstDigit}{lastDigit}");
		}

		Console.WriteLine(sum);
		Console.Read();
	}
}