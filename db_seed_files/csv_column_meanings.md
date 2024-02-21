## Plane database
The OpenFlights plane database contains a curated selection of 173 passenger aircraft with IATA and/or ICAO codes, covering the vast majority of flights operated today and commonly used in flight schedules and reservation systems. Each entry contains the following information:

Name	Full name of the aircraft.
IATA code	Unique three-letter IATA identifier for the aircraft.
ICAO code	Unique four-letter ICAO identifier for the aircraft.
The data is UTF-8 encoded. The special value \N is used for "NULL" to indicate that no value is available, and is understood automatically by MySQL if imported.

## Country database
The OpenFlights country database contains a list of ISO 3166-1 country codes, which can be used to look up the human-readable country names for the codes used in the Airline and Airport tables. Each entry contains the following information:

name	Full name of the country or territory.
iso_code	Unique two-letter ISO 3166-1 code for the country or territory.
dafif_code	FIPS country codes as used in DAFIF.Obsolete and primarily of historical interested.
The data is UTF-8 encoded. The special value \N is used for "NULL" to indicate that no value is available, and is understood automatically by MySQL if imported.


## Airline database
As of January 2012, the OpenFlights Airlines Database contains 5888 airlines. Each entry contains the following information:

Airline ID	Unique OpenFlights identifier for this airline.
Name	Name of the airline.
Alias	Alias of the airline. For example, All Nippon Airways is commonly known as "ANA".
IATA	2-letter IATA code, if available.
ICAO	3-letter ICAO code, if available.
Callsign	Airline callsign.
Country	Country or territory where airport is located. See Countries to cross-reference to ISO 3166-1 codes.
Active	"Y" if the airline is or has until recently been operational, "N" if it is defunct. This field is not reliable: in particular, major airlines that stopped flying long ago, but have not had their IATA code reassigned (eg. Ansett/AN), will incorrectly show as "Y".


## Plane database
The OpenFlights plane database contains a curated selection of 173 passenger aircraft with IATA and/or ICAO codes, covering the vast majority of flights operated today and commonly used in flight schedules and reservation systems. Each entry contains the following information:

Name	Full name of the aircraft.
IATA code	Unique three-letter IATA identifier for the aircraft.
ICAO code	Unique four-letter ICAO identifier for the aircraft.
The data is UTF-8 encoded. The special value \N is used for "NULL" to indicate that no value is available, and is understood automatically by MySQL if imported.