'use client';

import React, { useEffect, useMemo, useRef } from 'react';
import { MapContainer, TileLayer, Marker, useMap, useMapEvents } from 'react-leaflet';
import L from 'leaflet';

export interface BreakdownMapProps {
  latitude: number;
  longitude: number;
  onLocationChange: (lat: number, lng: number) => void;
  className?: string;
}

// Custom automotive emergency pin
const createCustomPinIcon = () => {
  return L.divIcon({
    className: 'custom-breakdown-pin',
    html: `
      <div style="position: relative; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; transform: translate(-8px, -8px);">
        <div style="position: absolute; width: 32px; height: 32px; border-radius: 50%; background-color: rgba(217, 56, 41, 0.3); animation: ping 2s cubic-bezier(0, 0, 0.2, 1) infinite;"></div>
        <div style="position: relative; width: 16px; height: 16px; border-radius: 50%; background-color: #D93829; border: 2px solid #F0EEE8; box-shadow: 0 2px 8px rgba(0,0,0,0.6);"></div>
      </div>
    `,
    iconSize: [32, 32],
    iconAnchor: [16, 16],
  });
};

function MapEventHandler({
  onLocationChange,
}: {
  onLocationChange: (lat: number, lng: number) => void;
}) {
  useMapEvents({
    click(e) {
      onLocationChange(
        Number(e.latlng.lat.toFixed(6)),
        Number(e.latlng.lng.toFixed(6)),
      );
    },
  });
  return null;
}

function MapPanController({ lat, lng }: { lat: number; lng: number }) {
  const map = useMap();
  useEffect(() => {
    map.panTo([lat, lng], { animate: true });
  }, [lat, lng, map]);
  return null;
}

export default function BreakdownMap({
  latitude,
  longitude,
  onLocationChange,
  className = 'w-full h-full min-h-[340px]',
}: BreakdownMapProps) {
  const markerRef = useRef<L.Marker>(null);
  const pinIcon = useMemo(() => createCustomPinIcon(), []);

  const eventHandlers = useMemo(
    () => ({
      dragend() {
        const marker = markerRef.current;
        if (marker != null) {
          const pos = marker.getLatLng();
          onLocationChange(
            Number(pos.lat.toFixed(6)),
            Number(pos.lng.toFixed(6)),
          );
        }
      },
    }),
    [onLocationChange],
  );

  return (
    <div className={`relative ${className}`}>
      <MapContainer
        center={[latitude, longitude]}
        zoom={14}
        scrollWheelZoom={false}
        className="w-full h-full z-0"
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
        />
        <MapEventHandler onLocationChange={onLocationChange} />
        <MapPanController lat={latitude} lng={longitude} />
        <Marker
          draggable={true}
          eventHandlers={eventHandlers}
          position={[latitude, longitude]}
          ref={markerRef}
          icon={pinIcon}
        />
      </MapContainer>
    </div>
  );
}
