/**
 * Haversine Great-Circle Distance Calculation
 * Formula:
 * d = 2R * asin(sqrt(sin^2(dLat/2) + cos(lat1)*cos(lat2)*sin^2(dLon/2)))
 * R = 6371 km
 */
export function calculateHaversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const toRad = (angle: number) => (angle * Math.PI) / 180;
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

describe('Haversine Great-Circle Proximity Engine', () => {
  it('calculates zero distance for identical coordinates', () => {
    const distance = calculateHaversineDistance(40.7128, -74.006, 40.7128, -74.006);
    expect(distance).toBeCloseTo(0, 4);
  });

  it('accurately calculates distance between NYC City Hall and Brooklyn Bridge (~1.1 km)', () => {
    // NYC City Hall: 40.7128° N, 74.0060° W
    // Brooklyn Bridge: 40.7061° N, 73.9969° W
    const distance = calculateHaversineDistance(40.7128, -74.006, 40.7061, -73.9969);
    expect(distance).toBeGreaterThan(1.0);
    expect(distance).toBeLessThan(1.4);
  });

  it('identifies mechanics within a 25km operating radius', () => {
    const customerLat = 40.7128;
    const customerLon = -74.006;

    // Mechanic at 15 km away
    const nearbyMechanicLat = 40.8000;
    const nearbyMechanicLon = -73.9500;
    const dist1 = calculateHaversineDistance(customerLat, customerLon, nearbyMechanicLat, nearbyMechanicLon);
    expect(dist1).toBeLessThan(25);

    // Far away mechanic (e.g. Philadelphia ~130 km away)
    const farMechanicLat = 39.9526;
    const farMechanicLon = -75.1652;
    const dist2 = calculateHaversineDistance(customerLat, customerLon, farMechanicLat, farMechanicLon);
    expect(dist2).toBeGreaterThan(100);
  });
});
