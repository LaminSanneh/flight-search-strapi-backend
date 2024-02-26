INSERT INTO `flights_source_airport_links`
select null, source.flight_id, source.airport_id from (select flights.id as "flight_id", airports.id as "airport_id", name, city, country_name, iata_code, icao_code, origin_airport_code, destination_airport_code from flights join airports on origin_airport_code = iata_code where CHAR_LENGTH(origin_airport_code) = 3) as source;

INSERT INTO `flights_destination_airport_links`
select null, destination.flight_id, destination.airport_id from (select flights.id as "flight_id", airports.id as "airport_id", name, city, country_name, iata_code, icao_code, origin_airport_code, destination_airport_code from flights join airports on destination_airport_code = iata_code where CHAR_LENGTH(origin_airport_code) = 3) as destination;
