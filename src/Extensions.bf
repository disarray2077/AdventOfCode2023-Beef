using System.Collections;
namespace AoC;

namespace System
{
	extension StringView
	{
		public static operator StringView(Span<char8> str)
		{
			StringView sv;
			sv.mPtr = str.Ptr;
			sv.mLength = str.[Friend]mLength;
			return sv;
		}
	}

	extension Char8
	{
		public static Dictionary<char8, String> strings ~ DeleteDictionaryAndValues!(_);

		static this()
		{
			strings = new .();
			for (int i = 0; i < uint8.MaxValue; i++)
				strings.Add((.)i, new String()..Append((char8)i));
		}

		public String ToString()
		{
			return strings[(.)this];
		}
	}

	extension SizedArray<T, CSize>
	{
		public int Count(T value)
		{
			int count = 0;
			for (int i = 0; i < CSize; i++)
				if (mVal[i] == value)
					count += 1;
			return count;
		}
	}
}
