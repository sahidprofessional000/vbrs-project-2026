/**
 * Haversine Great-Circle Proximity Engine & Privacy Utilities
 * Formula:
 * d = 2R * asin(sqrt(sin^2(dLat/2) + cos(lat1)*cos(lat2)*sin^2(dLon/2)))
 * Earth Radius R = 6371 km
 */

export function calculateHaversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const R = 6371; // Earth radius in kilometers

  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Calculates a bounding box around a coordinate for spatial search indexing
 */
export function calculateBoundingBox(
  latitude: number,
  longitude: number,
  radiusKm: number,
): { minLat: number; maxLat: number; minLon: number; maxLon: number } {
  const latDelta = radiusKm / 111.0; // ~111 km per degree of latitude
  const lonDelta = radiusKm / (111.0 * Math.cos((latitude * Math.PI) / 180));

  return {
    minLat: Math.max(-90, latitude - latDelta),
    maxLat: Math.min(90, latitude + latDelta),
    minLon: Math.max(-180, longitude - Math.abs(lonDelta)),
    maxLon: Math.min(180, longitude + Math.abs(lonDelta)),
  };
}

/**
 * Protects technician location privacy by rounding/fuzzing coordinates
 * to approximately 1.1 km resolution (2 decimal places) for public searches
 */
export function fuzzCoordinates(
  latitude: number,
  longitude: number,
  decimals = 2,
): { latitude: number; longitude: number } {
  const factor = Math.pow(10, decimals);
  return {
    latitude: Math.round(latitude * factor) / factor,
    longitude: Math.round(longitude * factor) / factor,
  };
}

/**
 * Estimates technician arrival time in minutes based on distance
 * Assuming average urban/suburban response speed of 40 km/h + 3 min dispatch prep
 */
export function estimateArrivalTimeMinutes(distanceKm: number): number {
  const averageSpeedKmH = 40;
  const transitMinutes = (distanceKm / averageSpeedKmH) * 60;
  return Math.max(5, Math.round(transitMinutes + 3));
}
