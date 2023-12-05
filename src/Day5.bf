using System;
using System.IO;
using System.Linq;
using System.Collections;
using System.Diagnostics;

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

				[Inline]
				public int Convert(int source)
				{
					return destinationStart + (source - sourceStart);
				}

				[Inline]
				public bool IsInRange(int source)
				{
					return source >= sourceStart && source < sourceStart + length;
				}
			}

			List<RangeMap> maps = new .() ~ delete _;

			public int Convert(int source)
			{
				for (let map in ref maps)
				{
					if (map.IsInRange(source))
						return map.Convert(source);
				}
				return source;
			}

			[Inline]
			public void Add(RangeMap map)
			{
				maps.Add(map);
			}
		}

		enum MapType
		{
			SeedToSoil,
			SoilToFertilizer,
			FertilizerToWater,
			WaterToLight,
			LightToTemperature,
			TemperatureToHumidity,
			HumidityToLocation
		}

		public List<int> Seeds = new .() ~ delete _;
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
					Seeds.AddRange(line.Substring(7).Split(' ', .RemoveEmptyEntries).Select((s) => int.Parse(s).Value));
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
			Debug.Assert(RangeMaps.Count == Enum.GetCount<MapType>());
			return .Ok;
		}

		[Inline]
		public RangeMaps Get(MapType type)
		{
			return RangeMaps[(int)type];
		}
	}

	public static void Main()
	{
		let fs = scope FileStream();
		fs.Open("Day5_small.txt");
		let ss = scope StreamReader(fs);

		Almanac almanac = scope .();
		almanac.Parse(ss.ReadToEnd(.. scope .()));

		let soils = almanac.Seeds.Select((s) => almanac.Get(.SeedToSoil).Convert(s));
		let fertilizers = soils.Select((s) => almanac.Get(.SoilToFertilizer).Convert(s));
		let waters = fertilizers.Select((s) => almanac.Get(.FertilizerToWater).Convert(s));
		let lights = waters.Select((s) => almanac.Get(.WaterToLight).Convert(s));
		let temperatures = lights.Select((s) => almanac.Get(.LightToTemperature).Convert(s));
		let humidities = temperatures.Select((s) => almanac.Get(.TemperatureToHumidity).Convert(s));
		let locations = humidities.Select((s) => almanac.Get(.HumidityToLocation).Convert(s));

		Console.WriteLine(locations.Min());
		Console.Read();
	}
}