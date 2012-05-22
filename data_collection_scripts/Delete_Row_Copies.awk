BEGIN {
	FS = "|";
	OFS = "|"
}

{
	ROW[$1 OFS $2 OFS $3 OFS $4 OFS $5 OFS $6]++;
	if (ROW[$1 OFS $2 OFS $3 OFS $4 OFS $5 OFS $6] == 1) {
		print $0
	}
}
