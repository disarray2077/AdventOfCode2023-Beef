using System;
using System.IO;
using System.Linq;
using System.Collections;
using System.Diagnostics;
using System.Threading;

namespace AoC;

class Program
{
	class Almanac
	{
		public struct Range : this(int start, int end)
		{
			public int Length => end - start;

			public void Adjust(int offset) mut
			{
				this.start += offset;
				this.end += offset;
			}

			public void ShrinkLeft(int length) mut
			{
				this.start += length;
			}

			public void ShrinkRight(int length) mut
			{
				this.end -= length;
			}
		}

		class RangeMaps
		{
			struct RangeMap
			{
				public enum ConversionResult
				{
					case Ok;
					case Partial(Range remnantRange);
					case Fail;
				}

				public int destinationStart;
				public int sourceStart;
				public int length;

				public int SourceStart => sourceStart;
				public int SourceEnd => sourceStart + length;

				public ConversionResult Convert(ref Range source)
				{
					// Range is contained completely inside our range.
					if (source.start >= SourceStart && source.end <= SourceEnd)
					{
						source.Adjust(destinationStart - sourceStart);
						return .Ok;
					}
					// Range's right side is partially inside our range.
					else if (source.end - 1 >= SourceStart && source.end - 1 < SourceEnd)
					{
						Range remnantRange = .(source.start, SourceStart);
						source.ShrinkLeft(remnantRange.Length);
						source.Adjust(destinationStart - sourceStart);
						return .Partial(remnantRange);
					}
					// Range's left side is partially inside our range.
					else if (source.start >= SourceStart && source.start < SourceEnd)
					{
						Range remnantRange = .(SourceEnd, source.end);
						source.ShrinkRight(remnantRange.Length);
						source.Adjust(destinationStart - sourceStart);
						return .Partial(remnantRange);
					}
					// Range is completely outside our range.
					else
						return .Fail;
				}
			}

			List<RangeMap> maps = new .() ~ delete _;

			public RangeMap.ConversionResult Convert(ref Almanac.Range source)
			{
				for (let map in ref maps)
				{
					switch (map.Convert(ref source))
					{
					case .Ok:
						return .Ok;
					case .Partial(let remnantRange):
						return .Partial(remnantRange);
					case .Fail:
						continue;
					}
				}
				return .Fail;
			}

			[Inline]
			public void Add(RangeMap map)
			{
				maps.Add(map);
			}
		}

		public List<Range> Seeds = new .() ~ delete _;
		public List<RangeMaps> RangeMaps = new .() ~ delete _;

		public Result<void> Parse(StringView text)
		{
			RangeMaps currentMap = null;
			for (var line in text.Split('\n'))
			{
				line.Trim();
				if (line.Length == 0)
					continue;
				if (line.StartsWith("seeds: "))
				{
					var seedRanges = line.Substring(7).Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value).ToList(.. scope .());
					for (int i = 0; i < seedRanges.Count; i += 2)
						Seeds.Add(.(seedRanges[i], seedRanges[i] + seedRanges[i + 1]));
					continue;
				}
				if (line.EndsWith("map:"))
				{
					if (currentMap != null)
						RangeMaps.Add(currentMap);
					currentMap = new RangeMaps();
					continue;
				}
				Debug.Assert(currentMap != null);
				var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
				currentMap.Add(.() {
					destinationStart = rangeSplitter.GetNext(),
					sourceStart = rangeSplitter.GetNext(),
					length = rangeSplitter.GetNext()
				});
			}
			if (currentMap != null)
				RangeMaps.Add(currentMap);
			Debug.Assert(RangeMaps.Count == 7);
			return .Ok;
		}
	}

	public static void Main()
	{
		let sw = scope Stopwatch()..Start();

		let fs = scope FileStream();
		fs.Open("Day5.txt");
		let ss = scope StreamReader(fs);

		Almanac almanac = scope .();
		almanac.Parse(ss.ReadToEnd(.. scope .()));

		let rangeStack = almanac.Seeds.Select((s) => (range: s, mapIndex: 0)).ToList(.. scope .());
		let locations = scope List<Almanac.Range>();
		while (!rangeStack.IsEmpty)
		{
			var rangeInfo = rangeStack.PopFront();
			while (rangeInfo.mapIndex < almanac.RangeMaps.Count)
			{
				if (almanac.RangeMaps[rangeInfo.mapIndex].Convert(ref rangeInfo.range) case .Partial(let remnantRange))
					rangeStack.Add((remnantRange, rangeInfo.mapIndex));
				rangeInfo.mapIndex += 1;
			}
			locations.Add(rangeInfo.range);
		}

		Console.WriteLine(locations.Select((x) => x.start).Min());
		Console.WriteLine("Time Taken: {}", sw.Elapsed);
		Console.Read();
	}
}