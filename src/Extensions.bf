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
}