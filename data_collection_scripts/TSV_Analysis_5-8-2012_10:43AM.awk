BEGIN {
	OFS = "\",\"";
	FS = "\t";

	Current_Water = 0;
	Current_Juice = 0;
	Current_Broth = 0;
	Current_Food = 0;

	print\
		"\""\
		"Name",\
		"Date",\
		"Water",\
		"Juice",\
		"Broth",\
		"Food",\
		"Chief Complaint",\
		"Daily Summary"\
		"\""
}

{
	if ((($0 ~ /[Nn][Aa][Mm][Ee]/) || ($0 ~ /[Cc]\/?[Cc]/) || ($0 ~ /[WwJjBbFf]\/[WwJjBbFf]\/[WwJjBbFf]/) || ($0 ~ /[01]?[0-9]\/[0123]?[0-9]\/2?0?[10][015-9]/)) && (TSV_Table_Bit == 0)) {
		for (field_position = 1; field_position <= NF; field_position++) {
			if ($field_position ~ /[Nn][Aa][Mm][Ee]/) {
				Name_Bit = 1;
				Name_Position = field_position;
			}

			if ($field_position ~ /[Cc]\/?[Cc]/) {
				CC_Bit = 1;
				Chief_Complaint_Position = field_position;
			}

			if ($field_position ~ /[WwJjBbFf]\/[WwJjFfBb]\/[WwJjBbFf]/) {
				Tx_Bit = 1;
				Treatment_Position = field_position;
			}

			if (($field_position ~ /[01]?[0-9]\/[0123]?[0-9]\/2?0?[10][015-9]/) && (Current_Date == "")) {
				gsub(/[[:blank:]]/, "", $field_position);
				Current_Date = gensub(/.*([01]?[0-9]\/[0123]?[0-9]\/2?0?[10][015-9]).*/, "\\1", 1, $field_position);
				Summary_Position = field_position;
			}
		}

		if ((Name_Bit == 1) && (CC_Bit == 1) && (Tx_Bit == 1) && (Current_Date != "") && (TSV_Table_Bit == 0)) {
			TSV_Table_Bit = 1;
			header_row = NR;
		} else {
			1st_row_NF = NF;
			getline;
			for (field_position = field_position; field_position <= NF; field_position++) {
				if ($field_position ~ /[Nn][Aa][Mm][Ee]/) {
					Name_Bit = 1;
					Name_Position = field_position + 1st_row_NF;
				}
	
				if ($field_position ~ /[Cc]\/?[Cc]/) {
					CC_Bit = 1;
					Chief_Complaint_Position = field_position + 1st_row_NF;
				}
	
				if ($field_position ~ /[WwJjBbFf]\/[WwJjFfBb]\/[WwJjBbFf]/) {
					Tx_Bit = 1;
					Treatment_Position = field_position + 1st_row_NF;
				}
	
				if (($field_position ~ /[01]?[0-9]\/[0123]?[0-9]\/2?0?[10][015-9]/) && (Current_Date == "")) {
					gsub(/[[:blank:]]/, "", $field_position);
					Current_Date = gensub(/.*([01]?[0-9]\/[0123]?[0-9]\/2?0?[10][015-9]).*/, "\\1", 1, $field_position);
					Summary_Position = field_position + 1st_row_NF;
				}
			}

			if ((Name_Bit == 1) && (CC_Bit == 1) && (Tx_Bit == 1) && (Current_Date != "") && (TSV_Table_Bit == 0)) {
				TSV_Table_Bit = 1;
				header_row = NR;
			}
		}
	}

	if ($0 ~ /[Cc][Oo][Nn][Tt][Ee][Nn][Tt]-[Tt][Yy][Pp][Ee].*[Bb][Oo][Uu][Nn][Dd][Aa][Rr][Yy][^=]*=[^"]*"[^"]*"/) {
		Boundary_Marker = gensub(/.*[Bb][Oo][Uu][Nn][Dd][Aa][Rr][Yy][^=]*=[^"]*"([^"]+)".*/, "\\1", 1);
		gsub(/[$^*()+{}\[\]\.\?\/+]/, "\\\\&", Boundary_Marker);
	}
	if ((TSV_Table_Bit == 1) && ($0 ~ Boundary_Marker)) {
		Name_Bit = 0;
		CC_Bit = 0;
		Tx_Bit = 0;
		Current_Date = "";
		TSV_Table_Bit = 0;
	}

	if ((TSV_Table_Bit  == 1) && (NR > header_row)) {
		for (field_position = 1; field_position <= NF; field_position++) {
			for (offset = -1; offset <= 3; offset++) {
				if ((field_position == Name_Position + offset) && ($field_position ~ /[[:alpha:]].*[[:alpha:]]/) && ($field_position !~ /[0-9]/) && (Current_Name_Bit == 0)) {
					Current_Name_Bit = 1;
					gsub(/[[:punct:]]/, "", $field_position);
					gsub(/^[[:space:]]+|[[:space:]]+$/, "", $field_position);
					gsub(/[[:space:]]+/, " ", $field_position);
					Current_Name = gensub(/[^[:alpha:]]*([[:alpha:]].*[[:alpha:]]).*/, "\\1", 1, $field_position);
					break;
				}

				if ((field_position == Chief_Complaint_Position + offset) && ($field_position ~ /[[:alpha:]]{2}/) && ($field_position !~ /[VvRrWwJjBbFf][0-9]/) && (Chief_Complaint_Bit == 0)) {
					Chief_Complaint_Bit = 1;
					gsub(/^[[:space:]]+|[[:space:]]+$/, "", $field_position);
					gsub(/[[:space:]]+/, " ", $field_position);
					Current_Chief_Complaint = gensub(/[^[:alnum:][:punct:]]*([[:punct:]]*[[:alnum:]].*[[:alnum:]][[:punct:]]*).*/, "\\1", 1, $field_position);
					break;
				}

				if ((field_position == Treatment_Position + offset) && ($field_position ~ /[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]|^[[:space:]]*[0-9]+[VvRrWwLlAaCcPpJjBbSsGgUuFf]|^[[:space:]]*[0-9]+[[:space:]]*\+[[:space:]]*[0-9]+|^[[:space:]]*[0-9]+[[:space:]]*$|[VvRrWwLlAaCcPpJjBbSsGgUuFf][[:space:]]*\+[[:space:]]*[VvRrWwLlAaCcPpJjBbSsGgUuFf]/) && (Treatment_Bit == 0)) {
					Treatment_Bit = 1;
					Treatment_String = $field_position;
					gsub(/\)/, "", Treatment_String);
					gsub(/[[:space:]]/, "", Treatment_String);
					if (Treatment_String ~ /[0-9][VvRrWwLlAaCcPpJjBbSsGgUuFf][^\(\+0-9]/) {
						gsub(/[VvRrWwLlAaCcPpJjBbSsGgUuFf][^\(\+0-9]/, " &", Treatment_String);
					}
					if (Treatment_String ~ /[0-9][VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]/) {
						gsub(/[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]/, " &", Treatment_String);
					}
	
					if (Treatment_String ~ /[RrSsGgUuFf][0-9]/) {
						split(Treatment_String, FOOD, /[RrSsGgUuFf]/);
						for (food_element in FOOD) {
							if (FOOD[food_element] ~ /^[0-9]/) {
								Current_Food = Current_Food + gensub(/^([0-9]+).*/, "\\1", 1, FOOD[food_element]);
							}
						}
					}
					if (Treatment_String ~ /[0-9][SsGgUuFfRr]/) {
						split(Treatment_String, FOOD, /[RrSsGgUuFf]/);
						for (food_element in FOOD) {
							if (FOOD[food_element] ~ /[0-9]$/) {
								Current_Food = Current_Food + gensub(/[0-9]+$/, "\\1", 1, FOOD[food_element]);
							}
						}
					}
	
					if (Treatment_String ~ /[LlAaCcPpJjVv][0-9]/) {
						split(Treatment_String, JUICE, /[LlAaCcPpJjVv]/);
						for (juice_element in JUICE) {
							if (JUICE[juice_element] ~ /^[0-9]/) {
								Current_Juice = Current_Juice + gensub(/^([0-9]+).*/, "\\1", 1, JUICE[juice_element]);
							}
						}
					}
					if (Treatment_String ~ /[0-9][LlAaCcPpJjVv]/) {
						split(Treatment_String, JUICE, /[LlAaCcPpJjVv]/);
						for (juice_element in JUICE) {
							if (JUICE[juice_element] ~ /[0-9]$/) {
								Current_Juice = Current_Juice + gensub(/^([0-9]+).*/, "\\1", 1, JUICE[juice_element]);
							}
						}
					}
	
					if (Treatment_String ~ /[Ww][0-9]/) {
						split(Treatment_String, WATER, /[Ww]/);
						for (water_element in WATER) {
							if (WATER[water_element] ~ /^[0-9]/) {
								Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, WATER[water_element]);
							}
						}
					}
					if (Treatment_String ~ /[0-9][Ww]/) {
						split(Treatment_String, WATER, /[Ww]/);
						for (water_element in WATER) {
							if (WATER[water_element] ~ /[0-9]$/) {
								Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, WATER[water_element]);
							}
						}
					}
	
					if (Treatment_String ~ /[Bb][0-9]/) {
						split(Treatment_String, BROTH, /[Bb]/);
						for (broth_element in BROTH) {
							if (BROTH[broth_element] ~ /^[0-9]/) {
								Current_Broth = Current_Broth + gensub(/^([0-9]+).*/, "\\1", 1, BROTH[broth_element]);
							}
						}
					}
					if (Treatment_String ~ /[0-9]+[Bb]/) {
						split(Treatment_String, BROTH, /[Bb]/);
						for (broth_element in BROTH) {
							if (BROTH[broth_element] ~ /[0-9]$/) {
								Current_Broth = Current_Broth + gensub(/^([0-9]+).*/, "\\1", 1, BROTH[broth_element]);
							}
						}
					}

					if (Treatment_String ~ /^[0-9]+$/) {
						Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, Treatment_String);
					}

					if (Treatment_String ~ /^[0-9]+\+[0-9]+($|[^WwLlAaCcPpJjVvBbSsGgUuFfRr0-9])/) {
						Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, Treatment_String);
						Current_Food = Current_Food + gensub(/^[0-9]+\+([0-9]+).*/, "\\1", 1, Treatment_String);
					}

					if (Treatment_String ~ /[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]+\+[0-9]+($|[^0-9VvRrWwLlAaCcPpJjBbSsGgUuFf])/) {
						split(Treatment_String, GARBAGE, /[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]+\+[0-9]+($|[^0-9VvRrWwLlAaCcPpJjBbSsGgUuFf])/, SEPS);
						for (seps in SEPS) {
							Current_Food = Current_Food + gensub(/[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]+\+([0-9]+).*/, "\\1", 1, SEPS[seps]);
						}
					}
					break;
				}

				if ((field_position == Summary_Position + offset) && (($field_position ~ /[[:alpha:]]{2}/) && ($field_position !~ /[VvRrWwJjBbFf][0-9]/) || ($field_position ~ /[0-9]{2,3}\/[0-9]{2,3}/)) && (Summary_Bit == 0)) {
					Summary_Bit = 1;
					gsub(/^[[:space:]]+|[[:space:]]+$/, "", $field_position);
					gsub(/[[:space:]]+/, " ", $field_position);
					Current_Summary = gensub(/(.*)/, "\\1", 1, $field_position);
					break;
				}
			}

			if ((Current_Name_Bit == 1) && (Current_Date_Bit == 1) && (Chief_Complaint_Bit == 1) && (Treatment_Bit == 1) && (Summary_Bit == 1) && (Current_Summary != Current_Chief_Complaint) && (Current_Name != Current_Chief_Complaint)) {
				print\
					"\""\
					Current_Name,\
					Current_Date,\
					Current_Water,\
					Current_Juice,\
					Current_Broth,\
					Current_Food,\
					Current_Chief_Complaint,\
					Current_Summary\
					"\"";
				
				Current_Name_Bit = 0;
				Current_Date_Bit = 0;
				Chief_Complaint_Bit = 0;
				Treatment_Bit = 0;
				Summary_Bit = 0;

				Current_Food = 0;
				Current_Juice = 0;
				Current_Water = 0;
				Current_Broth = 0

				break
			}
		}
	}
}
