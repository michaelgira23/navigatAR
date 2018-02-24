/**
 * Reversal of the following Swift code (in Location.swift)
 * First argument - Latitude
 * Second argument - Longitude
 * Third argument - Offset North (in meters) (negative means Southwards)
 * Fourth argument - Offset East (in meters) (negative means Westwards)
 **/

/*
func distanceDeltas(with other: Location) -> (latitude: Double, longitude: Double, altitude: Double) {
//		// https://en.wikipedia.org/wiki/Geographic_coordinate_system#Expressing_latitude_and_longitude_as_linear_units
//		let latRadians = degreesToRadians(latitude)
//		// Swift compiler is having difficulty parsing these all inlined for whatever reason
//		let val1 = 559.82 * cos(2 * latRadians)
//		let val2 = 1.175 * cos(4 * latRadians)
//		let val3 = 0.0023 * cos(6 * latRadians)
//		let metersPerLatitude = 111132.92 - val1 + val2 - val3
//
//		let longRadians = degreesToRadians(longitude)
//		let metersPerLongitude = (111412.84 * cos(longRadians)) - (93.5 * cos(3 * longRadians)) + (0.118 * cos(5 * longRadians))
//
//		return (latitude: (other.latitude - latitude) * metersPerLatitude, longitude: (other.longitude - longitude) * metersPerLongitude, altitude: (other.altitude - altitude))

		let latDiff = other.latitude - coordinate.latitude
		let longDiff = other.longitude - coordinate.longitude
		let altDiff = other.altitude - altitude

		// Calculate offset (in meters)
		// https://gis.stackexchange.com/a/2964
		let averageLat = (coordinate.latitude + other.latitude) / 2

		let longOffset = longDiff * 111111
		let latOffset = latDiff * 111111 * cos(degreesToRadians(averageLat))

		return (latitude: latOffset, longitude: longOffset, altitude: altDiff)
	}
*/

const newCoordinates = convertCoordinates(Number(process.argv[2]), Number(process.argv[3]), Number(process.argv[4]), Number(process.argv[5]));
console.log(`New Coordinates - lat: ${newCoordinates.lat} long: ${newCoordinates.long}`);

function convertCoordinates(latitude, longitude, nDiff, eDiff) {
	const longDiff = eDiff / 111111;
	const latDiff = nDiff / (111111 * Math.cos(degreesToRadians(latitude)))

	const finalLat = latitude + latDiff;
	const finalLong = longitude + longDiff;

	return { lat: finalLat, long: finalLong }
}

function degreesToRadians(degrees) {
	return degrees * (Math.PI / 180);
}
