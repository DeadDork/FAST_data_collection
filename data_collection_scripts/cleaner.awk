{
	if ($0 ~ /<[Tt][Aa][Bb][Ll][Ee]/) {
		Table_Bit = 1;
	}
	if ($0 ~ /<\/[Tt][Aa][Bb][Ll][Ee]/) {
		Table_Bit = 0;
		print;
	}
	if (Table_Bit == 1) {
		printf "%s", $0
	}
}
