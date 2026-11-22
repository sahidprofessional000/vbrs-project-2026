'use client';

import React, { useEffect, useMemo, useRef } from 'react';
import { MapContainer, TileLayer, Marker, Circle, useMap } from 'react-leaflet';
import L from 'leaflet';

export interface RadarMapProps {
  latitude: number;
  longitude: number;
  radiusKm: number;
  isOnline: boolean;
  className?: string;
}

const createTechnicianRadarIcon = (isOnline: boolean) => {
  const color = isOnline ? '#2D8A58' : '#706E68';
  const pulseRgba = isOnline ? 'rgba(45, 138, 88, 0.35)' : 'rgba(112, 110, 104, 0.2)';

  return L.divIcon({
    className: 'custom-technician-radar-pin',
    html: `
      <div style="position: relative; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; transform: translate(-10px, -10px);">
        ${
          isOnline
            ? `<div style="position: absolute; width: 36px; height: 36px; border-radius: 50%; background-color: ${pulseRgba}; animation: ping 2.2s cubic-bezier(0, 0, 0.2, 1) infinite;"></div>`
            : ''
        }
        <div style="position: relative; width: 18px; height: 18px; border-radius: 50%; background-color: ${color}; border: 2px solid #F0EEE8; box-shadow: 0 2px 10px rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center;">
          <div style="width: 6px; height: 6px; border-radius: 50%; background-color: #F0EEE8;"></div>
        </div>
      </div>
    `,
    iconSize: [36, 36],
    iconAnchor: [18, 18],
  });
};

function MapPanController({ lat, lng }: { lat: number; lng: number }) {
  const map = useMap();
  useEffect(() => {
    map.panTo([lat, lng], { animate: true });
  }, [lat, lng, map]);
  return null;
}

export default function RadarMap({
  latitude,
  longitude,
  radiusKm,
  isOnline,
  className = 'w-full h-full min-h-[300px]',
}: RadarMapProps) {
  const markerRef = useRef<L.Marker>(null);
  const pinIcon = useMemo(() => createTechnicianRadarIcon(isOnline), [isOnline]);

  return (
    <div className={`relative ${className}`}>
      <MapContainer
        center={[latitude, longitude]}
        zoom={11}
        scrollWheelZoom={false}
        className="w-full h-full z-0"
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
        />
        <MapPanController lat={latitude} lng={longitude} />
        <Marker position={[latitude, longitude]} ref={markerRef} icon={pinIcon} />
        {isOnline && (
          <Circle
            center={[latitude, longitude]}
            radius={radiusKm * 1000}
            pathOptions={{
              color: '#2D8A58',
              fillColor: '#2D8A58',
              fillOpacity: 0.08,
              weight: 1.5,
              dashArray: '4, 4',
            }}
          />
        )}
      </MapContainer>
    </div>
  );
}
