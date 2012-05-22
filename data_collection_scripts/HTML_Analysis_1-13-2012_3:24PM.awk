BEGIN {
	OFS = "|";

	# This is purely informative, and doesn't have any effect.
#	Table_Bit = 0;
#	TD_Bit = 0; # No longer used.
#	Current_Date_Bit = 0;
#	TR_Count = 0;
#	Treatment_Bit = 0;
#	Chief_Complaint_Bit = 0;
#	Summary_Bit = 0;

	# Sets these values to "0" as opposed to "" for printing out "F10" as "0|0|0|10".
	Current_Water = 0;
	Current_Juice = 0;
	Current_Broth = 0;
	Current_Food = 0;

	# Prints header row.
	print\
		"Name",\
		"Date",\
		"Water",\
		"Juice",\
		"Broth",\
		"Food",\
		"Chief Complaint",\
		"Daily Summary"
}

{
	# If there is a table tag, then it resets all of the values and bits that occur only once per table. Also turns on the t_b.
	if ($0 ~ /<[Tt][Aa][Bb][Ll][Ee]/) {
		Table_Bit = 1;
		TR_Count = 0;
		Current_Date_Bit = 0;
		Header_Name_Bit = 0;
		Header_CC_Bit = 0;
		Header_Tx_Bit = 0;
		Header_Date_Bit = 0;
	} else {
		# If there is no table tag, but there is an end table tag, turns off t_b.
		if ($0 ~ /<\/[Tt][Aa][Bb][Ll][Ee]/) {
			Table_Bit = 0;
		}
	}

	# If the table tag is on.
	if (Table_Bit == 1) {

		# At each table row, sets the count of the table row and rests the values for all values that only occur once per row.
		if ($0 ~ /<[Tt][Rr]/) {
			TR_Count++;
			TD_Count = 0;
			Current_Name_Bit = 0;
			Treatment_Bit = 0;
			Chief_Complaint_Bit = 0;
			Summary_Bit = 0;

			Current_Name = "";
			Current_Chief_Complaint = "";
			Current_Summary = "";
			Treatment_String = "";
			Current_Food = 0;
			Current_Juice = 0;
			Current_Water = 0;
			Current_Broth = 0;
		}

		# Counts the table cell (in order to determine which space to read for certain values, e.g. name)
		if ($0 ~ /<[Tt][Dd]/) {
			TD_Count++;
		}

		# If it is the first row of the table. Sets the cell number for various fields, e.g. "name" typically corresponds to 3.
		# Some tables don't have a header row, hence the header bits.
		if ((TR_Count == 1) && (TD_Count > 0)) {

			# Name
			# Note that some tables have no room and suite number. If they do, then the offset is 2, otherwise 0.
			if ($0 ~ />[^<]*[Nn][Aa][Mm][Ee][^<]*</) {
				if (TD_Count == 1) {
					offset = 0;
				} else {
					offset = 2;
				}
				Name_TD_Count = TD_Count + offset;
				Header_Name_Bit = 1;
			}

			# Chief complaint
			if ($0 ~ />[^<]*([Cc]\/?[Cc]|[Dd][Xx])[^<]*</) {
				Chief_Complaint_TD_Count = TD_Count + offset;
				Header_CC_Bit = 1;
			}

			# Treatment
			if ($0 ~ />[^<]*([WwJjBbFf]\/[WwJjBbFf]\/[WwJjBbFf]|[Dd][Ii][Ee][Tt][[:space:]]*[Ss][Tt][Aa][Tt][Uu][Ss]|[Pp][Aa][Tt][Ii][Ee][Nn][Tt][[:space:]]*[Ii][Dd])[^<]*</) {
				Treatment_TD_Count = TD_Count + offset;
				Header_Tx_Bit = 1;
			}

			# Date
			# Some rows have the day's date as well as that of the previous day, hence the c_d_b.
			if (($0 ~ />[^<0-9]*[01]?[0-9]\/[0-3]?[0-9]\/2?0?'?[10][0-9][^<]*</) && (Current_Date_Bit == 0)) {
				Current_Date = gensub(/.*>[^<0-9]*([01]?[0-9]\/[0-3]?[0-9]\/2?0?'?[10][0-25-9])[^<]*<.*/, "\\1", 1);
				Patient_Update_TD_Count = TD_Count + offset;
				Current_Date_Bit = 1;
				Header_Date_Bit = 1;
			}
		}

		# For rows subsequent to the first row and the first row has "name", "cc", "tx", and "date".
		if ((TR_Count > 1) && (TD_Count > 0) && (Header_Name_Bit == 1) && (Header_CC_Bit == 1) && (Header_Tx_Bit == 1) && (Header_Date_Bit == 1)) {
			
			# Get rid of most HTML characters in the text to be printed.
			gsub(/&[[:space:]]*[Nn][[:space:]]*[Bb][[:space:]]*[Ss][[:space:]]*[Pp][[:space:]]*;/, "");
			gsub(/&[[:space:]]*#[[:space:]]*[0-9]+[[:space:]]*;/, "");
			gsub(/&[[:space:]]*[Qq][[:space:]]*[Uu][[:space:]]*[Oo][[:space:]]*[Tt][[:space:]]*;/, "");
			gsub(/&[[:space:]]*[Aa][[:space:]]*[Mm][[:space:]]*[Pp][[:space:]]*;/, "");
			gsub(/&[[:space:]]*[Gg][[:space:]]*[Tt][[:space:]]*;/, "");

			# NAME
			# Some names have horrible HTML, hence the splitting and rejoining.
			if ((TD_Count == Name_TD_Count) && ($0 ~ />[^<A-Za-z]*[A-Za-z][^<]*[A-Za-z][^<A-Za-z]*</)) {
				split($0, NAME_SPLIT_ARRAY, /<[^>]*>/);
				n = asorti(NAME_SPLIT_ARRAY, GARBAGE);
				for (i = 1; i <= n; i++) {
					Current_Name = Current_Name NAME_SPLIT_ARRAY[i];
				}
				# Cleans up the name a bit.
				gsub(/[[:space:]]+/, " ", Current_Name);
				gsub(/[[:punct:]]/, "", Current_Name);
				gsub(/^[[:space:]]+|[[:space:]]+$/, "", Current_Name);
				Current_Name_Bit = 1;
			}

			# CC
			# Some cc's are empty, but are filled in on subsequent days.
			# Like NAME, needs to be split, rejoined, and cleaned up.
#			if ((TD_Count == Chief_Complaint_TD_Count) && ($0 ~ />[^<]*[A-Za-z]{2}[^<]*</)) {
			if (TD_Count == Chief_Complaint_TD_Count) {
				split($0, CC_SPLIT_ARRAY, /<[^>]*>/);
				n = asorti(CC_SPLIT_ARRAY, GARBAGE);
				for (i = 1; i <= n; i++) {
					Current_Chief_Complaint = Current_Chief_Complaint CC_SPLIT_ARRAY[i];
				}
				gsub(/^[[:space:]]+|[[:space:]]+$/, "", Current_Chief_Complaint);
				gsub(/[[:space:]]+/, " ", Current_Chief_Complaint);
				Chief_Complaint_Bit = 1;
			}

			# TX
			if ((TD_Count == Treatment_TD_Count) && ($0 ~ />[^<]*[0-9][^<]*</)) {
				Treatment_Bit = 1;

				# Creates a TX string.
				split($0, TX_SPLIT_ARRAY, /<[^>]*>/);
				n = asorti(TX_SPLIT_ARRAY, GARBAGE);
				for (i = 1; i <= n; i++) {
					Treatment_String = Treatment_String TX_SPLIT_ARRAY[i];
				}

				# Cleans up TX string.
				# Dr. Gerschfeld claims that when you have in Tx a string of the form "(TX) TX", that the parenthesized treatment refers to the treatment plan, with the latter being the recording the actual treatment. After carefully combing through the data, I've discovered that this was instituted on November 11, 2011. Since that is out of the date range we are looking at, this will remain commented out.
#				if (Treatment_String ~ /\([[:space:]]*[VvRrWwLlAaCcPpJjBbSsGgUuFf][[:space:]]*[0-9][^\)]*[VvRrWwLlAaCcPpJjBbSsGgUuFf][[:space:]]*[0-9]+[[:space:]]*\)/) {
#					gsub(/\([^\)]*[VvRrWwLlAaCcPpJjBbSsGgUuFf][^\)]*[0-9][^\)]*\)/, "", Treatment_String);
#				}
				gsub(/\)/, "", Treatment_String);
				gsub(/[[:space:]]/, "", Treatment_String);
				if (Treatment_String ~ /[0-9][VvRrWwLlAaCcPpJjBbSsGgUuFf][^\+\(0-9]/) {
					gsub(/[VvRrWwLlAaCcPpJjBbSsGgUuFf][^\(\+0-9]/, " &", Treatment_String);
				}
				if (Treatment_String ~ /[0-9][VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]/) {
					gsub(/[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]/, " &", Treatment_String);
				}

				# Food
				if (Treatment_String ~ /[RrSsGgUuFf][0-9]/) {
					split(Treatment_String, FOOD, /[RrSsGgUuFf]/);
					n = asort(FOOD);
					for (food_element = 1; food_element <= n; food_element++) {
						if (FOOD[food_element] ~ /^[0-9]/) {
							Current_Food = Current_Food + gensub(/^([0-9]+).*/, "\\1", 1, FOOD[food_element]);
						}
					}
				}
				if (Treatment_String ~ /[0-9][RrSsGgUuFf]/) {
					split(Treatment_String, FOOD, /[RrSsGgUuFf]/);
					n = asort(FOOD);
					for (food_element = 1; food_element <= n; food_element++) {
						if (FOOD[food_element] ~ /[0-9]$/) {
							match(FOOD[food_element], /[0-9]+$/, TEMP);
							Current_Food = Current_Food + TEMP[0];
						}
					}
				}

				# Juice
				if (Treatment_String ~ /[LlAaCcPpJjVv][0-9]/) {
					split(Treatment_String, JUICE, /[LlAaCcPpJjVv]/);
					n = asort(JUICE);
					for (juice_element = 1; juice_element <= n; juice_element++) {
						if (JUICE[juice_element] ~ /^[0-9]/) {
							Current_Juice = Current_Juice + gensub(/^([0-9]+).*/, "\\1", 1, JUICE[juice_element]);
						}
					}
				}
				if (Treatment_String ~ /[0-9][LlAaCcPpJjVv]/) {
					split(Treatment_String, JUICE, /[LlAaCcPpJjVv]/);
					n = asort(JUICE);
					for (juice_element = 1; juice_element <= n; juice_element++) {
						if (JUICE[juice_element] ~ /[0-9]$/) {
							match(JUICE[juice_element], /[0-9]+$/, TEMP);
							Current_Juice = Current_Juice + TEMP[0];
						}
					}
				}

				# Water
				if (Treatment_String ~ /[Ww][0-9]/) {
					split(Treatment_String, WATER, /[Ww]/);
					n = asort(WATER);
					for (water_element = 1; water_element <= n; water_element++) {
						if (WATER[water_element] ~ /^[0-9]/) {
							Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, WATER[water_element]);
						}
					}
				}
				if (Treatment_String ~ /[0-9][Ww]/) {
					split(Treatment_String, WATER, /[Ww]/);
					n = asort(WATER);
					for (water_element = 1; water_element <= n; water_element++) {
						if (WATER[water_element] ~ /[0-9]$/) {
							match(WATER[water_element], /[0-9]+$/, TEMP);
							Current_Water = Current_Water + TEMP[0];
						}
					}
				}

				# Broth
				if (Treatment_String ~ /[Bb][0-9]/) {
					split(Treatment_String, BROTH, /[Bb]/);
					n = asort(BROTH);
					for (broth_element = 1; broth_element <= n; broth_element++) {
						if (BROTH[broth_element] ~ /^[0-9]/) {
							Current_Broth = Current_Broth + gensub(/^([0-9]+).*/, "\\1", 1, BROTH[broth_element]);
						}
					}
				}
				if (Treatment_String ~ /[0-9][Bb]/) {
					split(Treatment_String, BROTH, /[Bb]/);
					n = asort(BROTH);
					for (broth_element = 1; broth_element <= n; broth_element++) {
						if (BROTH[broth_element] ~ /[0-9]$/) {
							match(BROTH[broth_element], /[0-9]+$/, TEMP);
							Current_Broth = Current_Broth + TEMP[0];
						}
					}
				}

				# Just a number (indicates just water). E.G. "5" indicates "5 days of water".
				if (Treatment_String ~ /^[0-9]+$/) {
					Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, Treatment_String);
				}

				# At least two strings of numbers. E.G. "5 + 3 + w7j3F9" indicates "13|3|0|12".
				if (Treatment_String ~ /^[0-9]+\+[0-9]+($|[^WwLlAaCcPpJjVvBbSsGgUuFfRr0-9])/) {
					Current_Water = Current_Water + gensub(/^([0-9]+).*/, "\\1", 1, Treatment_String);
					Current_Food = Current_Food + gensub(/^[0-9]+\+([0-9]+).*/, "\\1", 1, Treatment_String);
				}

				# A non-food tx followed by a number that is NOT followed by any tx indicator.
				if (Treatment_String ~ /[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]+\+[0-9]+($|[^0-9VvRrWwLlAaCcPpJjBbSsGgUuFf])/) {
					split(Treatment_String, GARBAGE, /[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]+\+[0-9]+($|[^0-9VvRrWwLlAaCcPpJjBbSsGgUuFf])/, SEPS);
					for (seps in SEPS) {
						Current_Food = Current_Food + gensub(/[VvRrWwLlAaCcPpJjBbSsGgUuFf][0-9]+\+([0-9]+).*/, "\\1", 1, SEPS[seps]);
					}
				}
			}

			# Daily summary
			# An empty row indicates that there is nothing to report (CTCAE score of 0).
#			if ((TD_Count == Patient_Update_TD_Count) && ($0 ~ />[^<]*([A-Za-z]{2}|[0-9]{2,3}\/[0-9]{2,3})[^<]*</)) {
			if (TD_Count == Patient_Update_TD_Count) {
				split($0, CURRENT_SUMMARY_ARRAY, /<[^>]*>/);
				n = asorti(CURRENT_SUMMARY_ARRAY, GARBAGE);
				for (i = 1; i <= n; i++) {
					Current_Summary = Current_Summary CURRENT_SUMMARY_ARRAY[i];
				}
				gsub(/^[[:space:]]+|[[:space:]]+$/, "", Current_Summary);
				gsub(/[[:space:]]+/, " ", Current_Summary);
				Summary_Bit = 1;
			}

			# If the row has data for NAME, CC, TX, and SUMMARY, then print.
			if ((Current_Name_Bit == 1) && (Current_Date_Bit == 1) && (Chief_Complaint_Bit == 1) && (Treatment_Bit == 1) && (Summary_Bit == 1)) {
				print\
					Current_Name,\
					Current_Date,\
					Current_Water,\
					Current_Juice,\
					Current_Broth,\
					Current_Food,\
					Current_Chief_Complaint,\
					Current_Summary
			}
		}
	}
}
