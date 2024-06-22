package utils

import "math"

type Position struct {
	Latitude  float64
	Longitude float64
}

const earthRadiusKm = 6371

func ComputeDistanceInNauticalMiles(p1, p2 Position) float64 {
	distance := ComputeDistanceInKm(p1, p2)
	distanceNM := distance * 0.539957

	return distanceNM
}

func ComputeDistanceInKm(p1, p2 Position) float64 {
	// Convert latitude and longitude from degrees to radians
	lat1 := p1.Latitude * math.Pi / 180
	lon1 := p1.Longitude * math.Pi / 180
	lat2 := p2.Latitude * math.Pi / 180
	lon2 := p2.Longitude * math.Pi / 180

	// Haversine formula
	deltaLat := lat2 - lat1
	deltaLon := lon2 - lon1

	a := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) + math.Cos(lat1)*math.Cos(lat2)*math.Sin(deltaLon/2)*math.Sin(deltaLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	// Distance in kilometers
	distance := earthRadiusKm * c

	// Convert distance to nautical miles
	distanceNM := distance * 0.539957

	return distanceNM
}
