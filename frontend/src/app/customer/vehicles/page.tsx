'use client';

import React, { useState, useEffect } from 'react';
import { api } from '@/lib/api';
import { Vehicle, PowertrainType } from '@/types';
import { 
  Car, 
  Plus, 
  Star, 
  Edit3, 
  Trash2, 
  Zap, 
  Fuel, 
  Leaf, 
  Flame, 
  ShieldAlert, 
  AlertCircle, 
  CheckCircle2, 
  Loader2, 
  X 
} from 'lucide-react';

export default function VehiclesPage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // Modal states
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingVehicle, setEditingVehicle] = useState<Vehicle | null>(null);
  const [deletingVehicleId, setDeletingVehicleId] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form states
  const [formData, setFormData] = useState({
    make: '',
    model: '',
    year: new Date().getFullYear(),
    licensePlate: '',
    vin: '',
    color: '',
    powertrain: 'PETROL' as PowertrainType,
    isDefault: false,
  });

  const fetchVehicles = async () => {
    setIsLoading(true);
    try {
      const data = await api.get<Vehicle[]>('/vehicles');
      setVehicles(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch vehicles from garage');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchVehicles();
  }, []);

  const resetForm = () => {
    setFormData({
      make: '',
      model: '',
      year: new Date().getFullYear(),
      licensePlate: '',
      vin: '',
      color: '',
      powertrain: 'PETROL',
      isDefault: vehicles.length === 0,
    });
    setError(null);
  };

  const handleOpenAddModal = () => {
    resetForm();
    setIsAddModalOpen(true);
  };

  const handleOpenEditModal = (vehicle: Vehicle) => {
    setEditingVehicle(vehicle);
    setFormData({
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      licensePlate: vehicle.licensePlate,
      vin: vehicle.vin || '',
      color: vehicle.color || '',
      powertrain: vehicle.powertrain,
      isDefault: vehicle.isDefault,
    });
    setError(null);
  };

  const handleCreateVehicle = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);

    try {
      await api.post('/vehicles', {
        ...formData,
        year: Number(formData.year),
      });
      setIsAddModalOpen(false);
      setSuccessMessage('Vehicle added to garage successfully');
      setTimeout(() => setSuccessMessage(null), 4000);
      await fetchVehicles();
    } catch (err: any) {
      setError(err.message || 'Failed to create vehicle');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdateVehicle = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingVehicle) return;

    setIsSubmitting(true);
    setError(null);

    try {
      await api.put(`/vehicles/${editingVehicle.id}`, {
        ...formData,
        year: Number(formData.year),
      });
      setEditingVehicle(null);
      setSuccessMessage('Vehicle updated successfully');
      setTimeout(() => setSuccessMessage(null), 4000);
      await fetchVehicles();
    } catch (err: any) {
      setError(err.message || 'Failed to update vehicle');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleSetDefault = async (vehicleId: string) => {
    try {
      await api.patch(`/vehicles/${vehicleId}/default`);
      setSuccessMessage('Primary vehicle updated');
      setTimeout(() => setSuccessMessage(null), 3000);
      await fetchVehicles();
    } catch (err: any) {
      setError(err.message || 'Failed to set default vehicle');
    }
  };

  const handleDeleteVehicle = async (vehicleId: string) => {
    try {
      await api.delete(`/vehicles/${vehicleId}`);
      setDeletingVehicleId(null);
      setSuccessMessage('Vehicle removed from garage');
      setTimeout(() => setSuccessMessage(null), 3000);
      await fetchVehicles();
    } catch (err: any) {
      setError(err.message || 'Failed to delete vehicle');
    }
  };

  const renderPowertrainIcon = (type: PowertrainType) => {
    switch (type) {
      case 'ELECTRIC':
        return <Zap className="w-3.5 h-3.5 text-cyan-400" />;
      case 'HYBRID':
        return <Leaf className="w-3.5 h-3.5 text-emerald-400" />;
      case 'CNG':
        return <Flame className="w-3.5 h-3.5 text-amber-400" />;
      default:
        return <Fuel className="w-3.5 h-3.5 text-slate-400" />;
    }
  };

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-slate-850">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">My Vehicle Garage</h1>
            <span className="px-2.5 py-0.5 rounded-full bg-slate-800 text-xs font-mono text-slate-300 font-semibold border border-slate-700">
              {vehicles.length} {vehicles.length === 1 ? 'CAR' : 'CARS'}
            </span>
          </div>
          <p className="text-sm text-slate-400 mt-1">
            Manage your registered automobiles for instant one-touch roadside breakdown dispatch.
          </p>
        </div>

        <button
          onClick={handleOpenAddModal}
          className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-sky-600 hover:bg-sky-500 active:bg-sky-700 text-white font-semibold text-sm shadow-md shadow-sky-950/40 transition-all shrink-0"
        >
          <Plus className="w-4 h-4" />
          <span>Add Vehicle</span>
        </button>
      </div>

      {/* Notifications */}
      {successMessage && (
        <div className="p-3.5 rounded-xl bg-emerald-950/60 border border-emerald-800/80 text-emerald-300 text-sm flex items-center gap-2 animate-fadeIn">
          <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
          <span>{successMessage}</span>
        </div>
      )}

      {error && (
        <div className="p-3.5 rounded-xl bg-rose-950/60 border border-rose-800/80 text-rose-300 text-sm flex items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <AlertCircle className="w-4 h-4 text-rose-400 shrink-0" />
            <span>{error}</span>
          </div>
          <button onClick={() => setError(null)} className="text-rose-400 hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Loading Skeletons */}
      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map((n) => (
            <div key={n} className="rounded-2xl bg-slate-900/60 border border-slate-850 p-6 space-y-4 animate-pulse">
              <div className="h-6 w-3/4 bg-slate-800 rounded-lg" />
              <div className="h-4 w-1/2 bg-slate-800/60 rounded-lg" />
              <div className="h-10 w-full bg-slate-850 rounded-xl" />
            </div>
          ))}
        </div>
      ) : vehicles.length === 0 ? (
        /* Empty State */
        <div className="rounded-2xl bg-slate-900/40 border border-slate-850 p-12 text-center max-w-xl mx-auto my-12">
          <div className="w-16 h-16 rounded-2xl bg-slate-850 border border-slate-800 text-slate-400 flex items-center justify-center mx-auto mb-4">
            <Car className="w-8 h-8 text-sky-400" />
          </div>
          <h3 className="text-lg font-bold text-white">Your Garage is Empty</h3>
          <p className="text-sm text-slate-400 mt-1 max-w-md mx-auto">
            Add your primary vehicle now so you can immediately request roadside assistance when encountering a breakdown.
          </p>
          <button
            onClick={handleOpenAddModal}
            className="mt-6 inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-sky-600 hover:bg-sky-500 text-white font-semibold text-sm shadow-md transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Register Your First Car</span>
          </button>
        </div>
      ) : (
        /* Vehicle Cards Grid */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {vehicles.map((v) => (
            <div
              key={v.id}
              className={`rounded-2xl bg-slate-900/90 border p-6 flex flex-col justify-between transition-all hover:shadow-xl relative overflow-hidden group ${
                v.isDefault ? 'border-sky-500/50 shadow-sky-950/20' : 'border-slate-800 hover:border-slate-700'
              }`}
            >
              {/* Default Badge Indicator */}
              {v.isDefault && (
                <div className="absolute top-0 right-0 bg-gradient-to-l from-sky-500 to-sky-600 text-white text-[10px] font-mono font-bold uppercase tracking-wider px-3 py-1 rounded-bl-xl shadow-md flex items-center gap-1">
                  <Star className="w-3 h-3 fill-current" />
                  <span>PRIMARY</span>
                </div>
              )}

              <div>
                {/* Year & Powertrain Header */}
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-xs font-mono font-semibold text-sky-400">{v.year}</span>
                  <span className="text-slate-600">•</span>
                  <div className="inline-flex items-center gap-1 text-[11px] font-mono px-2 py-0.5 rounded-md bg-slate-950 border border-slate-800 text-slate-300">
                    {renderPowertrainIcon(v.powertrain)}
                    <span>{v.powertrain}</span>
                  </div>
                </div>

                {/* Make & Model */}
                <h3 className="text-xl font-bold text-white tracking-tight">{v.make} {v.model}</h3>

                {/* License Plate Display (Automotive Monospace Badge) */}
                <div className="mt-4 p-3 rounded-xl bg-slate-950 border border-slate-800/90 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] text-slate-500 font-mono uppercase tracking-wider block">License Plate</span>
                    <span className="font-mono font-bold text-base text-slate-100 tracking-wider">{v.licensePlate}</span>
                  </div>
                  {v.color && (
                    <div className="text-right">
                      <span className="text-[10px] text-slate-500 font-mono uppercase tracking-wider block">Color</span>
                      <span className="text-xs font-medium text-slate-300">{v.color}</span>
                    </div>
                  )}
                </div>

                {v.vin && (
                  <div className="mt-2 text-[11px] font-mono text-slate-500 truncate">
                    VIN: <span className="text-slate-400">{v.vin}</span>
                  </div>
                )}
              </div>

              {/* Action Buttons */}
              <div className="mt-6 pt-4 border-t border-slate-850 flex items-center justify-between gap-2">
                {!v.isDefault ? (
                  <button
                    onClick={() => handleSetDefault(v.id)}
                    className="text-xs text-slate-400 hover:text-sky-400 font-medium flex items-center gap-1.5 transition-colors"
                  >
                    <Star className="w-3.5 h-3.5" />
                    <span>Set Primary</span>
                  </button>
                ) : (
                  <span className="text-xs text-sky-400/90 font-mono flex items-center gap-1">
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    <span>Selected Default</span>
                  </span>
                )}

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleOpenEditModal(v)}
                    title="Edit Vehicle"
                    className="p-2 rounded-lg text-slate-400 hover:text-white hover:bg-slate-850 transition-colors"
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>

                  <button
                    onClick={() => setDeletingVehicleId(v.id)}
                    title="Delete Vehicle"
                    className="p-2 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-slate-850 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* ADD VEHICLE MODAL */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fadeIn">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 shadow-2xl relative">
            <div className="flex items-center justify-between pb-4 border-b border-slate-800">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-sky-950 border border-sky-800 text-sky-400 flex items-center justify-center">
                  <Car className="w-4 h-4" />
                </div>
                <h3 className="text-lg font-bold text-white">Add Vehicle to Garage</h3>
              </div>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="text-slate-500 hover:text-white p-1 rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateVehicle} className="mt-5 space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Make *</label>
                  <input
                    type="text"
                    required
                    value={formData.make}
                    onChange={(e) => setFormData({ ...formData, make: e.target.value })}
                    placeholder="e.g. Toyota"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-sky-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Model *</label>
                  <input
                    type="text"
                    required
                    value={formData.model}
                    onChange={(e) => setFormData({ ...formData, model: e.target.value })}
                    placeholder="e.g. Camry"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-sky-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Year *</label>
                  <input
                    type="number"
                    required
                    min={1970}
                    max={new Date().getFullYear() + 1}
                    value={formData.year}
                    onChange={(e) => setFormData({ ...formData, year: Number(e.target.value) })}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-sky-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">License Plate *</label>
                  <input
                    type="text"
                    required
                    value={formData.licensePlate}
                    onChange={(e) => setFormData({ ...formData, licensePlate: e.target.value })}
                    placeholder="e.g. 7XYZ890"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm uppercase font-mono focus:outline-none focus:border-sky-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Powertrain</label>
                  <select
                    value={formData.powertrain}
                    onChange={(e) => setFormData({ ...formData, powertrain: e.target.value as PowertrainType })}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-sky-500"
                  >
                    <option value="PETROL">Petrol / Gasoline</option>
                    <option value="DIESEL">Diesel</option>
                    <option value="ELECTRIC">Full Electric (EV)</option>
                    <option value="HYBRID">Hybrid</option>
                    <option value="CNG">CNG / Compressed Gas</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Color</label>
                  <input
                    type="text"
                    value={formData.color}
                    onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                    placeholder="e.g. Midnight Black"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-sky-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-mono text-slate-300 uppercase mb-1">VIN (Optional)</label>
                <input
                  type="text"
                  value={formData.vin}
                  onChange={(e) => setFormData({ ...formData, vin: e.target.value })}
                  placeholder="17-character VIN number"
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm font-mono focus:outline-none focus:border-sky-500"
                />
              </div>

              <div className="flex items-center gap-3 pt-2">
                <input
                  type="checkbox"
                  id="add-default-check"
                  checked={formData.isDefault}
                  onChange={(e) => setFormData({ ...formData, isDefault: e.target.checked })}
                  className="w-4 h-4 rounded text-sky-600 bg-slate-950 border-slate-800 focus:ring-sky-500"
                />
                <label htmlFor="add-default-check" className="text-sm text-slate-300">
                  Set as Primary Vehicle for emergency reports
                </label>
              </div>

              <div className="pt-4 flex justify-end gap-3 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2.5 rounded-xl bg-slate-800 text-slate-300 hover:text-white text-sm font-medium"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-5 py-2.5 rounded-xl bg-sky-600 hover:bg-sky-500 text-white text-sm font-semibold flex items-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting && <Loader2 className="w-4 h-4 animate-spin" />}
                  <span>Save Vehicle</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* EDIT VEHICLE MODAL */}
      {editingVehicle && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fadeIn">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 shadow-2xl relative">
            <div className="flex items-center justify-between pb-4 border-b border-slate-800">
              <h3 className="text-lg font-bold text-white">Edit {editingVehicle.make} {editingVehicle.model}</h3>
              <button
                onClick={() => setEditingVehicle(null)}
                className="text-slate-500 hover:text-white p-1 rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleUpdateVehicle} className="mt-5 space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Make</label>
                  <input
                    type="text"
                    required
                    value={formData.make}
                    onChange={(e) => setFormData({ ...formData, make: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm"
                  />
                </div>
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Model</label>
                  <input
                    type="text"
                    required
                    value={formData.model}
                    onChange={(e) => setFormData({ ...formData, model: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Color</label>
                  <input
                    type="text"
                    value={formData.color}
                    onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm"
                  />
                </div>
                <div>
                  <label className="block text-xs font-mono text-slate-300 uppercase mb-1">Powertrain</label>
                  <select
                    value={formData.powertrain}
                    onChange={(e) => setFormData({ ...formData, powertrain: e.target.value as PowertrainType })}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm"
                  >
                    <option value="PETROL">Petrol</option>
                    <option value="DIESEL">Diesel</option>
                    <option value="ELECTRIC">Electric (EV)</option>
                    <option value="HYBRID">Hybrid</option>
                    <option value="CNG">CNG</option>
                  </select>
                </div>
              </div>

              <div className="flex items-center gap-3 pt-2">
                <input
                  type="checkbox"
                  id="edit-default-check"
                  checked={formData.isDefault}
                  onChange={(e) => setFormData({ ...formData, isDefault: e.target.checked })}
                  className="w-4 h-4 rounded text-sky-600 bg-slate-950 border-slate-800"
                />
                <label htmlFor="edit-default-check" className="text-sm text-slate-300">
                  Set as Primary Vehicle
                </label>
              </div>

              <div className="pt-4 flex justify-end gap-3 border-t border-slate-800">
                <button
                  type="button"
                  onClick={() => setEditingVehicle(null)}
                  className="px-4 py-2.5 rounded-xl bg-slate-800 text-slate-300 hover:text-white text-sm font-medium"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-5 py-2.5 rounded-xl bg-sky-600 hover:bg-sky-500 text-white text-sm font-semibold flex items-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting && <Loader2 className="w-4 h-4 animate-spin" />}
                  <span>Save Changes</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DELETE CONFIRMATION DIALOG */}
      {deletingVehicleId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fadeIn">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-md w-full p-6 shadow-2xl">
            <div className="w-12 h-12 rounded-xl bg-rose-950/60 border border-rose-800/80 text-rose-400 flex items-center justify-center mb-4">
              <ShieldAlert className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-white">Remove Vehicle from Garage?</h3>
            <p className="text-sm text-slate-400 mt-2 leading-relaxed">
              Are you sure you want to remove this vehicle from your account? This action cannot be undone.
            </p>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setDeletingVehicleId(null)}
                className="px-4 py-2 rounded-xl bg-slate-800 text-slate-300 hover:text-white text-sm font-medium"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDeleteVehicle(deletingVehicleId)}
                className="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-500 text-white text-sm font-semibold"
              >
                Delete Vehicle
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
