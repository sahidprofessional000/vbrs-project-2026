'use client';

import React, { useEffect, useMemo, useRef } from 'react';
import { MapContainer, TileLayer, Marker, Polyline, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';

export interface TrackingMapProps {
  incidentLat: number;
  incidentLng: number;
  mechanicLat?: number | null;
  mechanicLng?: number | null;
  mechanicHeading?: number | null;
  mechanicName?: string | null;
  status: string;
  isStale?: boolean;
  className?: string;
}

// Custom Incident Marker (Pulsing Crimson Beacon)
const createIncidentIcon = () => {
  return L.divIcon({
    className: 'custom-incident-marker',
    html: `
      <div style="position: relative; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; transform: translate(-12px, -12px);">
        <div style="position: absolute; width: 40px; height: 40px; border-radius: 50%; background-color: rgba(217, 56, 41, 0.35); animation: ping 2s cubic-bezier(0, 0, 0.2, 1) infinite;"></div>
        <div style="position: relative; width: 22px; height: 22px; border-radius: 50%; background-color: #D93829; border: 2.5px solid #F0EEE8; box-shadow: 0 4px 12px rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center;">
          <div style="width: 6px; height: 6px; border-radius: 50%; background-color: #F0EEE8;"></div>
        </div>
      </div>
    `,
    iconSize: [40, 40],
    iconAnchor: [20, 20],
  });
};

// Custom Mechanic Marker (Directional Sage Green Vehicle Pin)
const createMechanicIcon = (heading?: number | null, isStale?: boolean) => {
  const bg = isStale ? '#706E68' : '#2D8A58';
  const rotation = heading ?? 0;

  return L.divIcon({
    className: 'custom-mechanic-marker',
    html: `
      <div style="position: relative; width: 42px; height: 42px; display: flex; align-items: center; justify-content: center; transform: translate(-13px, -13px);">
        <div style="position: absolute; width: 34px; height: 34px; border-radius: 50%; background-color: ${bg}; border: 2px solid #F0EEE8; box-shadow: 0 4px 14px rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center; transform: rotate(${rotation}deg);">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#F0EEE8" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polygon points="12 2 19 21 12 17 5 21 12 2"></polygon>
          </svg>
        </div>
      </div>
    `,
    iconSize: [42, 42],
    iconAnchor: [21, 21],
  });
};

// Map Viewport Controller to fit both points smoothly
function MapBoundsController({
  incidentLat,
  incidentLng,
  mechanicLat,
  mechanicLng,
}: {
  incidentLat: number;
  incidentLng: number;
  mechanicLat?: number | null;
  mechanicLng?: number | null;
}) {
  const map = useMap();

  useEffect(() => {
    if (
      mechanicLat !== null &&
      mechanicLat !== undefined &&
      mechanicLng !== null &&
      mechanicLng !== undefined
    ) {
      const bounds = L.latLngBounds([
        [incidentLat, incidentLng],
        [mechanicLat, mechanicLng],
      ]);
      map.fitBounds(bounds, { padding: [60, 60], maxZoom: 15, animate: true });
    } else {
      map.setView([incidentLat, incidentLng], 14, { animate: true });
    }
  }, [incidentLat, incidentLng, mechanicLat, mechanicLng, map]);

  return null;
}

export default function TrackingMap({
  incidentLat,
  incidentLng,
  mechanicLat,
  mechanicLng,
  mechanicHeading,
  mechanicName,
  status,
  isStale = false,
  className = 'w-full h-full min-h-[360px]',
}: TrackingMapProps) {
  const incidentIcon = useMemo(() => createIncidentIcon(), []);
  const mechanicIcon = useMemo(
    () => createMechanicIcon(mechanicHeading, isStale),
    [mechanicHeading, isStale],
  );

  const hasMechanicCoords =
    mechanicLat !== null &&
    mechanicLat !== undefined &&
    mechanicLng !== null &&
    mechanicLng !== undefined;

  return (
    <div className={`relative ${className}`}>
      <MapContainer
        center={[incidentLat, incidentLng]}
        zoom={13}
        scrollWheelZoom={false}
        className="w-full h-full z-0"
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
        />

        <MapBoundsController
          incidentLat={incidentLat}
          incidentLng={incidentLng}
          mechanicLat={mechanicLat}
          mechanicLng={mechanicLng}
        />

        {/* Incident Breakdown Marker */}
        <Marker position={[incidentLat, incidentLng]} icon={incidentIcon}>
          <Popup className="custom-architectural-popup">
            <div className="font-mono text-xs p-1 space-y-1">
              <div className="text-crimson font-semibold uppercase">Breakdown Incident Site</div>
              <div className="text-stone-muted text-[10px]">
                {incidentLat.toFixed(5)}, {incidentLng.toFixed(5)}
              </div>
            </div>
          </Popup>
        </Marker>

        {/* Mechanic En-Route Marker & Vector Polyline */}
        {hasMechanicCoords && (
          <>
            <Marker
              position={[mechanicLat as number, mechanicLng as number]}
              icon={mechanicIcon}
            >
              <Popup className="custom-architectural-popup">
                <div className="font-mono text-xs p-1 space-y-1">
                  <div className="text-sage-light font-semibold uppercase">
                    {mechanicName || 'Field Technician'}
                  </div>
                  <div className="text-stone-muted text-[10px]">
                    Status: {status} • {isStale ? 'Signal Stale' : 'Live GPS'}
                  </div>
                </div>
              </Popup>
            </Marker>

            <Polyline
              positions={[
                [incidentLat, incidentLng],
                [mechanicLat as number, mechanicLng as number],
              ]}
              pathOptions={{
                color: isStale ? '#706E68' : '#2D8A58',
                weight: 2,
                dashArray: '6, 6',
                opacity: 0.85,
              }}
            />
          </>
        )}
      </MapContainer>
    </div>
  );
}
