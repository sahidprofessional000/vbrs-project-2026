'use client';

import React, { useState, useEffect } from 'react';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { Vehicle, PowertrainType } from '@/types';
import { 
  Plus, 
  Check, 
  AlertCircle, 
  CheckCircle2, 
  Loader2, 
  X,
  Trash2,
  Edit2,
  ShieldAlert
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
      setSuccessMessage('Vehicle successfully registered to fleet');
      setTimeout(() => setSuccessMessage(null), 4000);
      await fetchVehicles();
    } catch (err: any) {
      setError(err.message || 'Failed to register vehicle');
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
      setSuccessMessage('Vehicle specification updated');
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
      setSuccessMessage('Primary emergency vehicle updated');
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
      setSuccessMessage('Vehicle removed from registry');
      setTimeout(() => setSuccessMessage(null), 3000);
      await fetchVehicles();
    } catch (err: any) {
      setError(err.message || 'Failed to delete vehicle');
    }
  };

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />
      <main className="flex-1 layout-container py-10">
        <div className="space-y-8">
      {/* Editorial Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-6 pb-6 border-b border-divider/60">
        <div className="space-y-1.5">
          <div className="flex items-center gap-2">
            <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
              Personal Fleet Registry
            </span>
            <span className="text-divider">•</span>
            <span className="text-[11px] font-mono text-stone-muted">
              {vehicles.length} {vehicles.length === 1 ? 'UNIT' : 'UNITS'} ACTIVE
            </span>
          </div>
          <h1 className="text-3xl font-medium tracking-tight text-porcelain">
            Registered Automobiles
          </h1>
        </div>

        <button
          onClick={handleOpenAddModal}
          className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-sm bg-porcelain hover:bg-porcelain-dim text-carbon font-medium text-xs font-mono uppercase tracking-wider transition-colors shrink-0"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>Add Automobile</span>
        </button>
      </div>

      {/* Notifications */}
      {successMessage && (
        <div className="p-3.5 border border-sage/40 bg-sage-subtle text-porcelain text-xs font-mono flex items-center gap-2.5">
          <CheckCircle2 className="w-4 h-4 text-sage-light shrink-0" />
          <span>{successMessage}</span>
        </div>
      )}

      {error && (
        <div className="p-3.5 border border-crimson/50 bg-crimson-subtle text-porcelain text-xs font-mono flex items-center justify-between gap-2.5">
          <div className="flex items-center gap-2.5">
            <AlertCircle className="w-4 h-4 text-crimson shrink-0" />
            <span>{error}</span>
          </div>
          <button onClick={() => setError(null)} className="text-stone-muted hover:text-porcelain">
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Loading Skeletons */}
      {isLoading ? (
        <div className="border border-divider divide-y divide-divider bg-graphite/40">
          {[1, 2, 3].map((n) => (
            <div key={n} className="p-6 flex items-center justify-between animate-pulse">
              <div className="space-y-2">
                <div className="h-4 w-48 bg-elevated rounded-sm" />
                <div className="h-3 w-32 bg-elevated/60 rounded-sm" />
              </div>
              <div className="h-8 w-24 bg-elevated rounded-sm" />
            </div>
          ))}
        </div>
      ) : vehicles.length === 0 ? (
        /* Empty State */
        <div className="border border-divider bg-graphite/40 p-12 text-center max-w-lg mx-auto my-12 space-y-4">
          <div className="text-xs font-mono text-stone-dim uppercase tracking-widest">
            Registry Status // Null
          </div>
          <h3 className="text-lg font-medium text-porcelain">No Registered Vehicles</h3>
          <p className="text-xs text-stone-muted leading-relaxed font-normal">
            Enrolling your vehicle ensures rapid one-click emergency dispatch with accurate vehicle specifications and towing requirements.
          </p>
          <div className="pt-2">
            <button
              onClick={handleOpenAddModal}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-sm bg-porcelain text-carbon font-medium text-xs font-mono uppercase tracking-wider hover:bg-porcelain-dim transition-colors"
            >
              <Plus className="w-3.5 h-3.5" />
              <span>Register First Car</span>
            </button>
          </div>
        </div>
      ) : (
        /* Architectural Fleet Table / Grid */
        <div className="border border-divider divide-y divide-divider bg-graphite/60">
          {vehicles.map((v) => (
            <div
              key={v.id}
              className="p-6 sm:p-7 flex flex-col md:flex-row md:items-center justify-between gap-6 hover:bg-graphite transition-colors"
            >
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <span className="font-mono text-xs text-stone-dim font-medium">{v.year}</span>
                  <h3 className="text-lg font-medium text-porcelain tracking-tight">
                    {v.make} {v.model}
                  </h3>
                  {v.isDefault && (
                    <span className="px-2 py-0.5 rounded-sm border border-porcelain/30 text-porcelain text-[10px] font-mono uppercase tracking-wider">
                      Primary Vehicle
                    </span>
                  )}
                </div>

                <div className="flex flex-wrap items-center gap-4 text-xs font-mono text-stone-muted">
                  <div className="px-2.5 py-1 bg-carbon border border-divider text-porcelain">
                    Plate: <span className="font-semibold">{v.licensePlate}</span>
                  </div>

                  <div className="px-2.5 py-1 bg-carbon border border-divider">
                    Powertrain: <span className="text-porcelain">{v.powertrain}</span>
                  </div>

                  {v.color && (
                    <div className="text-stone-dim">
                      Color: <span className="text-stone-muted">{v.color}</span>
                    </div>
                  )}

                  {v.vin && (
                    <div className="text-stone-dim hidden lg:block">
                      VIN: <span className="text-stone-muted">{v.vin}</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center gap-3 pt-2 md:pt-0">
                {!v.isDefault && (
                  <button
                    onClick={() => handleSetDefault(v.id)}
                    className="px-3 py-1.5 border border-divider hover:border-divider-strong bg-carbon text-stone-muted hover:text-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
                  >
                    Set Primary
                  </button>
                )}

                <button
                  onClick={() => handleOpenEditModal(v)}
                  title="Edit Specifications"
                  className="p-2 border border-divider hover:border-divider-strong bg-carbon text-stone-muted hover:text-porcelain transition-colors"
                >
                  <Edit2 className="w-3.5 h-3.5" />
                </button>

                <button
                  onClick={() => setDeletingVehicleId(v.id)}
                  title="Remove Automobile"
                  className="p-2 border border-divider hover:border-crimson/60 bg-carbon text-stone-muted hover:text-crimson transition-colors"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* ADD VEHICLE MODAL */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-carbon/85 backdrop-blur-sm">
          <div className="bg-graphite border border-divider max-w-lg w-full p-8 shadow-elevated">
            <div className="flex items-center justify-between pb-4 border-b border-divider">
              <h3 className="text-base font-medium text-porcelain">Register Automobile</h3>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="text-stone-dim hover:text-porcelain"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleCreateVehicle} className="mt-6 space-y-4 font-mono text-xs">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Manufacturer *</label>
                  <input
                    type="text"
                    required
                    value={formData.make}
                    onChange={(e) => setFormData({ ...formData, make: e.target.value })}
                    placeholder="e.g. Porsche"
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none focus:border-stone-muted rounded-none"
                  />
                </div>
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Model *</label>
                  <input
                    type="text"
                    required
                    value={formData.model}
                    onChange={(e) => setFormData({ ...formData, model: e.target.value })}
                    placeholder="e.g. 911 Carrera"
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none focus:border-stone-muted rounded-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Year *</label>
                  <input
                    type="number"
                    required
                    min={1970}
                    max={new Date().getFullYear() + 1}
                    value={formData.year}
                    onChange={(e) => setFormData({ ...formData, year: Number(e.target.value) })}
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none focus:border-stone-muted rounded-none"
                  />
                </div>
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">License Plate *</label>
                  <input
                    type="text"
                    required
                    value={formData.licensePlate}
                    onChange={(e) => setFormData({ ...formData, licensePlate: e.target.value })}
                    placeholder="e.g. 7XYZ890"
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain uppercase focus:outline-none focus:border-stone-muted rounded-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Powertrain</label>
                  <select
                    value={formData.powertrain}
                    onChange={(e) => setFormData({ ...formData, powertrain: e.target.value as PowertrainType })}
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none focus:border-stone-muted rounded-none"
                  >
                    <option value="PETROL">Petrol (Internal Combustion)</option>
                    <option value="DIESEL">Diesel</option>
                    <option value="ELECTRIC">Full Electric (BEV)</option>
                    <option value="HYBRID">Hybrid (PHEV / HEV)</option>
                    <option value="CNG">Compressed Natural Gas</option>
                  </select>
                </div>
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Exterior Color</label>
                  <input
                    type="text"
                    value={formData.color}
                    onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                    placeholder="e.g. Slate Gray"
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none focus:border-stone-muted rounded-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-stone-dim uppercase mb-1.5">VIN (Optional)</label>
                <input
                  type="text"
                  value={formData.vin}
                  onChange={(e) => setFormData({ ...formData, vin: e.target.value })}
                  placeholder="17-character chassis number"
                  className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none focus:border-stone-muted rounded-none"
                />
              </div>

              <div className="flex items-center gap-3 pt-3">
                <input
                  type="checkbox"
                  id="add-default-vehicle"
                  checked={formData.isDefault}
                  onChange={(e) => setFormData({ ...formData, isDefault: e.target.checked })}
                  className="rounded-none bg-carbon border-divider text-porcelain focus:ring-0"
                />
                <label htmlFor="add-default-vehicle" className="text-stone-muted text-xs font-sans">
                  Designate as primary vehicle for one-touch roadside dispatch
                </label>
              </div>

              <div className="pt-6 flex justify-end gap-3 border-t border-divider">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2 border border-divider text-stone-muted hover:text-porcelain uppercase tracking-wider"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-5 py-2 bg-porcelain text-carbon font-medium uppercase tracking-wider hover:bg-porcelain-dim flex items-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                  <span>Enroll Vehicle</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* EDIT VEHICLE MODAL */}
      {editingVehicle && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-carbon/85 backdrop-blur-sm">
          <div className="bg-graphite border border-divider max-w-lg w-full p-8 shadow-elevated">
            <div className="flex items-center justify-between pb-4 border-b border-divider">
              <h3 className="text-base font-medium text-porcelain">
                Edit {editingVehicle.make} {editingVehicle.model}
              </h3>
              <button
                onClick={() => setEditingVehicle(null)}
                className="text-stone-dim hover:text-porcelain"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleUpdateVehicle} className="mt-6 space-y-4 font-mono text-xs">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Manufacturer</label>
                  <input
                    type="text"
                    required
                    value={formData.make}
                    onChange={(e) => setFormData({ ...formData, make: e.target.value })}
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none rounded-none"
                  />
                </div>
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Model</label>
                  <input
                    type="text"
                    required
                    value={formData.model}
                    onChange={(e) => setFormData({ ...formData, model: e.target.value })}
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none rounded-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Exterior Color</label>
                  <input
                    type="text"
                    value={formData.color}
                    onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none rounded-none"
                  />
                </div>
                <div>
                  <label className="block text-stone-dim uppercase mb-1.5">Powertrain</label>
                  <select
                    value={formData.powertrain}
                    onChange={(e) => setFormData({ ...formData, powertrain: e.target.value as PowertrainType })}
                    className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain focus:outline-none rounded-none"
                  >
                    <option value="PETROL">Petrol</option>
                    <option value="DIESEL">Diesel</option>
                    <option value="ELECTRIC">Electric</option>
                    <option value="HYBRID">Hybrid</option>
                    <option value="CNG">CNG</option>
                  </select>
                </div>
              </div>

              <div className="flex items-center gap-3 pt-3">
                <input
                  type="checkbox"
                  id="edit-default-vehicle"
                  checked={formData.isDefault}
                  onChange={(e) => setFormData({ ...formData, isDefault: e.target.checked })}
                  className="rounded-none bg-carbon border-divider text-porcelain focus:ring-0"
                />
                <label htmlFor="edit-default-vehicle" className="text-stone-muted text-xs font-sans">
                  Designate as primary vehicle
                </label>
              </div>

              <div className="pt-6 flex justify-end gap-3 border-t border-divider">
                <button
                  type="button"
                  onClick={() => setEditingVehicle(null)}
                  className="px-4 py-2 border border-divider text-stone-muted hover:text-porcelain uppercase tracking-wider"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-5 py-2 bg-porcelain text-carbon font-medium uppercase tracking-wider hover:bg-porcelain-dim flex items-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                  <span>Save Modifications</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DELETE CONFIRMATION DIALOG */}
      {deletingVehicleId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-carbon/85 backdrop-blur-sm">
          <div className="bg-graphite border border-divider max-w-md w-full p-8 shadow-elevated">
            <h3 className="text-base font-medium text-porcelain">Remove Vehicle from Fleet?</h3>
            <p className="text-xs text-stone-muted mt-2 leading-relaxed font-normal">
              This action will detach the automobile profile from your emergency garage. Historical breakdown records will remain preserved in the audit log.
            </p>
            <div className="mt-6 flex justify-end gap-3 font-mono text-xs uppercase tracking-wider">
              <button
                onClick={() => setDeletingVehicleId(null)}
                className="px-4 py-2 border border-divider text-stone-muted hover:text-porcelain"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDeleteVehicle(deletingVehicleId)}
                className="px-4 py-2 bg-crimson hover:bg-crimson-hover text-porcelain font-medium"
              >
                Confirm Removal
              </button>
            </div>
          </div>
        </div>
      )}
        </div>
      </main>
    </div>
  );
}
