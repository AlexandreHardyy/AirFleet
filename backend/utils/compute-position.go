package utils

import "math"

type Position struct {
	Latitude  float64
	Longitude float64
}

func ComputeDistanceInNauticalMiles(p1, p2 Position) float64 {
	distance := ComputeDistanceInKm(p1, p2)
	distanceNM := distance * 0.539957

	return math.Round(distanceNM*100) / 100
}

func ComputeDistanceInKm(pos1, pos2 Position) float64 {
	const earthRadiusKm = 6371 // Rayon de la Terre en kilomètres

	lat1 := pos1.Latitude * math.Pi / 180
	lon1 := pos1.Longitude * math.Pi / 180
	lat2 := pos2.Latitude * math.Pi / 180
	lon2 := pos2.Longitude * math.Pi / 180

	deltaLat := lat2 - lat1
	deltaLon := lon2 - lon1

	a := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) + math.Cos(lat1)*math.Cos(lat2)*math.Sin(deltaLon/2)*math.Sin(deltaLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	distance := earthRadiusKm * c

	return math.Round(distance*100) / 100
}
