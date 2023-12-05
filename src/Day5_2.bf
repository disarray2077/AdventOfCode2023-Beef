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
		class RangeMaps
		{
			struct RangeMap
			{
				public int destinationStart;
				public int sourceStart;
				public int length;
	
				public int Convert(int source)
				{
					Debug.Assert(IsInRange(source));
					return destinationStart + (source - sourceStart);
				}

				public bool IsInRange(int source)
				{
					if (source >= sourceStart && source < sourceStart + length)
						return true;
					return false;
				}
			}

			List<RangeMap> maps = new .() ~ delete _;

			public int Convert(int source)
			{
				for (let map in maps)
				{
					if (map.IsInRange(source))
						return map.Convert(source);
				}
				return source;
			}

			public void Add(RangeMap map)
			{
				maps.Add(map);
			}
		}

		public List<Enumerable.RangeEnumerable<int>> Seeds = new .() ~ delete _;
		public RangeMaps SeedToSoil = new .() ~ delete _;
		public RangeMaps SoilToFertilizer = new .() ~ delete _;
		public RangeMaps FertilizerToWater = new .() ~ delete _;
		public RangeMaps WaterToLight = new .() ~ delete _;
		public RangeMaps LightToTemperature = new .() ~ delete _;
		public RangeMaps TemperatureToHumidity = new .() ~ delete _;
		public RangeMaps HumidityToLocation = new .() ~ delete _;

		public Result<void> Parse(StringView text)
		{
			StringView currentSection = "";
			for (let line in text.Split('\n'))
			{
				if (line.Length == 0)
					continue;
				if (line.StartsWith("seeds: "))
				{
					var seedRanges = line.Substring(7).Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value).ToList(.. scope .());
					for (int i = 0; i < seedRanges.Count; i += 2)
						Seeds.Add(Enumerable.Range(seedRanges[i], seedRanges[i] + seedRanges[i + 1]));
					continue;
				}
				if (line.EndsWith("map:"))
				{
					currentSection = Try!(line.Split(' ').GetNext());
					continue;
				}
				Debug.Assert(!currentSection.IsEmpty);
				switch (currentSection)
				{
				case "seed-to-soil":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					SeedToSoil.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				case "soil-to-fertilizer":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					SoilToFertilizer.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				case "fertilizer-to-water":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					FertilizerToWater.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				case "water-to-light":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					WaterToLight.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				case "light-to-temperature":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					LightToTemperature.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				case "temperature-to-humidity":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					TemperatureToHumidity.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				case "humidity-to-location":
					var rangeSplitter = line.Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value);
					HumidityToLocation.Add(.() {
						destinationStart = rangeSplitter.GetNext(),
						sourceStart = rangeSplitter.GetNext(),
						length = rangeSplitter.GetNext()
					});
				default:
					Runtime.NotImplemented();
				}
			}
			return .Ok;
		}
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day5.txt");
		let ss = scope StreamReader(fs);

		Almanac almanac = scope .();
		almanac.Parse(ss.ReadToEnd(.. scope .()));

		int minLocation = int.MaxValue;
		Monitor lock = scope .();
		int totalRun = 0;
		for (let seedGenerator in almanac.Seeds)
		{
			ThreadPool.QueueUserWorkItem(new [=seedGenerator, &lock, &totalRun, &minLocation, &almanac]() =>
			{
				let soils = seedGenerator.Select((s) => almanac.SeedToSoil.Convert(s));
				let fertilizers = soils.Select((s) => almanac.SoilToFertilizer.Convert(s));
				let waters = fertilizers.Select((s) => almanac.FertilizerToWater.Convert(s));
				let lights = waters.Select((s) => almanac.WaterToLight.Convert(s));
				let temperatures = lights.Select((s) => almanac.LightToTemperature.Convert(s));
				let humidities = temperatures.Select((s) => almanac.TemperatureToHumidity.Convert(s));
				let locations = humidities.Select((s) => almanac.HumidityToLocation.Convert(s));
				int min = locations.Min();
				using (lock.Enter())
				{
					if (minLocation > min)
						minLocation = min;
				}
				Interlocked.Increment(ref totalRun);
			});
		}

		while (totalRun != almanac.Seeds.Count)
			Thread.Sleep(1000);

		Console.WriteLine(minLocation);
		Console.Read();
	}
}