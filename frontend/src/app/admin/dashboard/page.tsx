'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { OriginalVehicleViewer } from '@/components/vehicle/original-vehicle-viewer';
import { api } from '@/lib/api';
import { 
  ShieldCheck, 
  Activity, 
  Users, 
  Wrench, 
  Clock, 
  AlertCircle, 
  Check, 
  X,
  Database,
  Search,
  Filter,
  FileText,
  AlertTriangle,
  ArrowRight,
  TrendingUp,
  Truck,
  Eye,
  RefreshCw,
  ExternalLink,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';

type TabType = 'analytics' | 'mechanics' | 'disputes' | 'audit-logs';

export default function AdminDashboardPage() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<TabType>('analytics');

  // Operational Analytics State
  const [analytics, setAnalytics] = useState<any>(null);
  const [isLoadingAnalytics, setIsLoadingAnalytics] = useState(true);

  // Field Technicians State
  const [mechanics, setMechanics] = useState<any[]>([]);
  const [mechanicStatusFilter, setMechanicStatusFilter] = useState<string>('ALL');
  const [isLoadingMechanics, setIsLoadingMechanics] = useState(false);
  const [selectedMechanic, setSelectedMechanic] = useState<any | null>(null);
  const [reviewNotes, setReviewNotes] = useState('');
  const [isSubmittingReview, setIsSubmittingReview] = useState(false);

  // Disputes & Grievances State
  const [complaints, setComplaints] = useState<any[]>([]);
  const [complaintStatusFilter, setComplaintStatusFilter] = useState<string>('ALL');
  const [isLoadingComplaints, setIsLoadingComplaints] = useState(false);
  const [selectedComplaint, setSelectedComplaint] = useState<any | null>(null);
  const [newComplaintStatus, setNewComplaintStatus] = useState<string>('INVESTIGATING');
  const [complaintResolutionNotes, setComplaintResolutionNotes] = useState('');
  const [isSubmittingComplaint, setIsSubmittingComplaint] = useState(false);

  // Audit Logs State
  const [auditLogs, setAuditLogs] = useState<any[]>([]);
  const [auditPagination, setAuditPagination] = useState({ total: 0, limit: 25, offset: 0, hasMore: false });
  const [auditActionFilter, setAuditActionFilter] = useState('');
  const [auditEntityFilter, setAuditEntityFilter] = useState('');
  const [isLoadingAudit, setIsLoadingAudit] = useState(false);
  const [inspectingLog, setInspectingLog] = useState<any | null>(null);

  // Error & Status Messages
  const [toastMessage, setToastMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  const showToast = (text: string, type: 'success' | 'error' = 'success') => {
    setToastMessage({ text, type });
    setTimeout(() => setToastMessage(null), 4000);
  };

  // 1. Fetch Analytics
  const fetchAnalytics = useCallback(async () => {
    setIsLoadingAnalytics(true);
    try {
      const data = await api.get('/admin/analytics/overview');
      setAnalytics(data);
    } catch (err: any) {
      console.error('Failed to load analytics overview:', err);
    } finally {
      setIsLoadingAnalytics(false);
    }
  }, []);

  // 2. Fetch Field Technicians
  const fetchMechanics = useCallback(async (status?: string) => {
    setIsLoadingMechanics(true);
    try {
      const query = status && status !== 'ALL' ? `?status=${status}` : '';
      const data = await api.get<any[]>(`/admin/mechanics${query}`);
      setMechanics(data);
    } catch (err: any) {
      console.error('Failed to fetch mechanics:', err);
    } finally {
      setIsLoadingMechanics(false);
    }
  }, []);

  // 3. Fetch Disputes
  const fetchComplaints = useCallback(async (status?: string) => {
    setIsLoadingComplaints(true);
    try {
      const query = status && status !== 'ALL' ? `?status=${status}` : '';
      const data = await api.get<any[]>(`/complaints${query}`);
      setComplaints(data);
    } catch (err: any) {
      console.error('Failed to fetch complaints:', err);
    } finally {
      setIsLoadingComplaints(false);
    }
  }, []);

  // 4. Fetch Audit Logs
  const fetchAuditLogs = useCallback(async (offset = 0) => {
    setIsLoadingAudit(true);
    try {
      const params = new URLSearchParams();
      params.append('limit', '25');
      params.append('offset', offset.toString());
      if (auditActionFilter.trim()) params.append('action', auditActionFilter.trim());
      if (auditEntityFilter.trim()) params.append('entityName', auditEntityFilter.trim());

      const data = await api.get<any>(`/admin/audit-logs?${params.toString()}`);
      setAuditLogs(data.logs || []);
      setAuditPagination(data.pagination || { total: 0, limit: 25, offset, hasMore: false });
    } catch (err: any) {
      console.error('Failed to fetch audit logs:', err);
    } finally {
      setIsLoadingAudit(false);
    }
  }, [auditActionFilter, auditEntityFilter]);

  // Load initial data based on active tab
  useEffect(() => {
    if (activeTab === 'analytics') {
      fetchAnalytics();
    } else if (activeTab === 'mechanics') {
      fetchMechanics(mechanicStatusFilter);
    } else if (activeTab === 'disputes') {
      fetchComplaints(complaintStatusFilter);
    } else if (activeTab === 'audit-logs') {
      fetchAuditLogs(0);
    }
  }, [activeTab, fetchAnalytics, fetchMechanics, fetchComplaints, fetchAuditLogs, mechanicStatusFilter, complaintStatusFilter]);

  // Handle Technician Verification Submission
  const handleVerifyMechanic = async (status: 'APPROVED' | 'REJECTED') => {
    if (!selectedMechanic) return;
    setIsSubmittingReview(true);
    try {
      await api.patch(`/admin/mechanics/${selectedMechanic.id}/verify`, {
        status,
        notes: reviewNotes.trim() || undefined,
      });
      showToast(`Technician ${selectedMechanic.user?.fullName} marked as ${status}.`, 'success');
      setSelectedMechanic(null);
      setReviewNotes('');
      fetchMechanics(mechanicStatusFilter);
    } catch (err: any) {
      showToast(err.message || 'Failed to update technician verification', 'error');
    } finally {
      setIsSubmittingReview(false);
    }
  };

  // Handle Dispute Status Update
  const handleUpdateComplaintStatus = async () => {
    if (!selectedComplaint) return;
    setIsSubmittingComplaint(true);
    try {
      await api.patch(`/admin/complaints/${selectedComplaint.id}/status`, {
        status: newComplaintStatus,
        resolutionNotes: complaintResolutionNotes.trim() || undefined,
      });
      showToast(`Dispute status updated to ${newComplaintStatus}.`, 'success');
      setSelectedComplaint(null);
      setComplaintResolutionNotes('');
      fetchComplaints(complaintStatusFilter);
    } catch (err: any) {
      showToast(err.message || 'Failed to advance dispute status', 'error');
    } finally {
      setIsSubmittingComplaint(false);
    }
  };

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 layout-container py-10 space-y-8">
        
        {/* Toast Notification */}
        {toastMessage && (
          <div className={`p-4 border font-mono text-xs flex items-center justify-between transition-all ${
            toastMessage.type === 'success' 
              ? 'border-sage/50 bg-sage-subtle text-porcelain' 
              : 'border-crimson/50 bg-crimson-subtle text-porcelain'
          }`}>
            <div className="flex items-center gap-2.5">
              {toastMessage.type === 'success' ? (
                <Check className="w-4 h-4 text-sage-light" />
              ) : (
                <AlertCircle className="w-4 h-4 text-crimson" />
              )}
              <span>{toastMessage.text}</span>
            </div>
            <button onClick={() => setToastMessage(null)} className="text-stone-dim hover:text-porcelain">
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
        )}

        {/* Executive Header */}
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-6 pb-6 border-b border-divider">
          <div className="space-y-1.5">
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                Platform Governance & Supervisory Terminal
              </span>
              <span className="text-divider">•</span>
              <span className="text-[11px] font-mono text-sage-light">
                REAL-TIME TELEMETRY ACTIVE
              </span>
            </div>
            <h1 className="text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
              Operational Command Center
            </h1>
            <p className="text-xs text-stone-muted font-normal max-w-2xl">
              Unified administrative governance: field technician verification, municipal disputes, real SQL operational analytics, and security audit logs.
            </p>
          </div>

          <div className="px-4 py-2 border border-divider bg-graphite font-mono text-xs text-stone-muted flex items-center gap-2.5">
            <span className="w-2 h-2 rounded-full bg-sage-light" />
            <span>SUPERVISOR // <span className="text-porcelain font-medium">{user?.fullName || 'Administrator'}</span></span>
          </div>
        </div>

        {/* Primary Tab Navigation */}
        <div className="flex items-center gap-2 border-b border-divider pb-px overflow-x-auto">
          <button
            onClick={() => setActiveTab('analytics')}
            className={`px-4 py-2.5 font-mono text-xs uppercase tracking-wider transition-colors border-b-2 flex items-center gap-2 whitespace-nowrap ${
              activeTab === 'analytics'
                ? 'border-porcelain text-porcelain font-medium bg-graphite/40'
                : 'border-transparent text-stone-muted hover:text-porcelain hover:bg-graphite/20'
            }`}
          >
            <Activity className="w-3.5 h-3.5" />
            <span>Operational Fleet Analytics</span>
          </button>

          <button
            onClick={() => setActiveTab('mechanics')}
            className={`px-4 py-2.5 font-mono text-xs uppercase tracking-wider transition-colors border-b-2 flex items-center gap-2 whitespace-nowrap ${
              activeTab === 'mechanics'
                ? 'border-porcelain text-porcelain font-medium bg-graphite/40'
                : 'border-transparent text-stone-muted hover:text-porcelain hover:bg-graphite/20'
            }`}
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Technician Credential Desk</span>
          </button>

          <button
            onClick={() => setActiveTab('disputes')}
            className={`px-4 py-2.5 font-mono text-xs uppercase tracking-wider transition-colors border-b-2 flex items-center gap-2 whitespace-nowrap ${
              activeTab === 'disputes'
                ? 'border-porcelain text-porcelain font-medium bg-graphite/40'
                : 'border-transparent text-stone-muted hover:text-porcelain hover:bg-graphite/20'
            }`}
          >
            <AlertTriangle className="w-3.5 h-3.5" />
            <span>Dispute & Grievance Desk</span>
          </button>

          <button
            onClick={() => setActiveTab('audit-logs')}
            className={`px-4 py-2.5 font-mono text-xs uppercase tracking-wider transition-colors border-b-2 flex items-center gap-2 whitespace-nowrap ${
              activeTab === 'audit-logs'
                ? 'border-porcelain text-porcelain font-medium bg-graphite/40'
                : 'border-transparent text-stone-muted hover:text-porcelain hover:bg-graphite/20'
            }`}
          >
            <Database className="w-3.5 h-3.5" />
            <span>Security Audit Log Explorer</span>
          </button>
        </div>

        {/* ========================================================================= */}
        {/* TAB 1: OPERATIONAL FLEET ANALYTICS (REAL SQL METRICS)                    */}
        {/* ========================================================================= */}
        {activeTab === 'analytics' && (
          <div className="space-y-8">
            {isLoadingAnalytics ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted animate-pulse">
                Querying PostgreSQL Aggregation Engine...
              </div>
            ) : (
              <>
                {/* Real Database KPIs Strip */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className="p-6 border border-divider bg-graphite space-y-1">
                    <span className="text-[11px] font-mono uppercase tracking-wider text-stone-dim">Total Breakdowns</span>
                    <div className="text-3xl font-medium tracking-tight text-porcelain">
                      {analytics?.fleetMetrics?.totalIncidents ?? 0}
                    </div>
                    <p className="text-[10px] font-mono text-stone-muted">Verified incidents filed</p>
                  </div>

                  <div className="p-6 border border-divider bg-graphite space-y-1">
                    <span className="text-[11px] font-mono uppercase tracking-wider text-stone-dim">Active Dispatches</span>
                    <div className="text-3xl font-medium tracking-tight text-ochre">
                      {analytics?.fleetMetrics?.activeDispatches ?? 0}
                    </div>
                    <p className="text-[10px] font-mono text-stone-muted">Missions in progress</p>
                  </div>

                  <div className="p-6 border border-divider bg-graphite space-y-1">
                    <span className="text-[11px] font-mono uppercase tracking-wider text-stone-dim">Completed Operations</span>
                    <div className="text-3xl font-medium tracking-tight text-sage-light">
                      {analytics?.fleetMetrics?.completedJobs ?? 0}
                    </div>
                    <p className="text-[10px] font-mono text-stone-muted">Succesfully serviced</p>
                  </div>

                  <div className="p-6 border border-divider bg-graphite space-y-1">
                    <span className="text-[11px] font-mono uppercase tracking-wider text-stone-dim">Towing Deployment</span>
                    <div className="text-3xl font-medium tracking-tight text-porcelain">
                      {analytics?.fleetMetrics?.towingPercentage ?? 0}%
                    </div>
                    <p className="text-[10px] font-mono text-stone-muted">{analytics?.fleetMetrics?.towingRequiredCount ?? 0} flatbed dispatches</p>
                  </div>
                </div>

                {/* Secondary Operational Metrics Strip */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 font-mono text-xs">
                  <div className="p-5 border border-divider bg-graphite/60 space-y-2">
                    <div className="flex items-center justify-between text-stone-dim">
                      <span className="uppercase">Avg Response Latency</span>
                      <Clock className="w-4 h-4 text-stone-muted" />
                    </div>
                    <div className="text-2xl font-medium text-porcelain">
                      {analytics?.responseTiming?.avgDispatchLatencyMinutes ?? 0} min
                    </div>
                    <p className="text-[11px] text-stone-dim">Timestamp delta from creation to acceptance</p>
                  </div>

                  <div className="p-5 border border-divider bg-graphite/60 space-y-2">
                    <div className="flex items-center justify-between text-stone-dim">
                      <span className="uppercase">Avg Service Duration</span>
                      <Wrench className="w-4 h-4 text-stone-muted" />
                    </div>
                    <div className="text-2xl font-medium text-porcelain">
                      {analytics?.responseTiming?.avgServiceDurationMinutes ?? 0} min
                    </div>
                    <p className="text-[11px] text-stone-dim">From arrival on scene to sign-off</p>
                  </div>

                  <div className="p-5 border border-divider bg-graphite/60 space-y-2">
                    <div className="flex items-center justify-between text-stone-dim">
                      <span className="uppercase">Field Workforce Ratio</span>
                      <Users className="w-4 h-4 text-stone-muted" />
                    </div>
                    <div className="text-2xl font-medium text-porcelain">
                      {analytics?.fleetMetrics?.approvedMechanics ?? 0} / {analytics?.fleetMetrics?.totalMechanics ?? 0}
                    </div>
                    <p className="text-[11px] text-stone-dim">
                      Approved technicians ({analytics?.fleetMetrics?.pendingMechanics ?? 0} awaiting vetting)
                    </p>
                  </div>
                </div>

                {/* Municipal Fleet Vehicle Asset Telemetry // 3D Inspection Stage */}
                <div className="border border-divider bg-graphite p-6 space-y-4">
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-divider">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                        <h3 className="font-medium text-porcelain text-sm">
                          Municipal Fleet Asset Inspection // 3D Realtime Stage
                        </h3>
                      </div>
                      <p className="text-xs text-stone-muted mt-0.5">
                        Interactive physical asset evaluation with PBR clearcoat shaders, finish swatches, and 360° turntable inspection.
                      </p>
                    </div>
                    <span className="text-[10px] font-mono text-stone-dim uppercase px-2 py-1 bg-carbon border border-divider">
                      REGISTERED FLEET ASSET
                    </span>
                  </div>

                  <OriginalVehicleViewer
                    variant="compact"
                    title="Municipal Fleet Vehicle Asset"
                  />
                </div>

                {/* Real Breakdown Category Distribution */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                  <div className="border border-divider bg-graphite p-6 space-y-5">
                    <div className="flex items-center justify-between pb-3 border-b border-divider">
                      <div>
                        <h3 className="font-medium text-porcelain text-sm">Breakdown Category Distribution</h3>
                        <p className="text-xs text-stone-muted">Aggregated SQL groupBy telemetry across incident records</p>
                      </div>
                      <span className="text-[10px] font-mono text-stone-dim uppercase">PostgreSQL SQL</span>
                    </div>

                    <div className="space-y-3.5">
                      {analytics?.categoryDistribution?.length > 0 ? (
                        analytics.categoryDistribution.map((item: any) => {
                          const maxCount = Math.max(...analytics.categoryDistribution.map((c: any) => c.count), 1);
                          const pct = Math.round((item.count / maxCount) * 100);
                          return (
                            <div key={item.category} className="space-y-1">
                              <div className="flex items-center justify-between text-xs font-mono">
                                <span className="text-porcelain uppercase">{item.category.replace(/_/g, ' ')}</span>
                                <span className="text-stone-muted">{item.count} Incidents</span>
                              </div>
                              <div className="h-2 w-full bg-carbon border border-divider overflow-hidden">
                                <div 
                                  className="h-full bg-porcelain/80 transition-all duration-500" 
                                  style={{ width: `${pct}%` }} 
                                />
                              </div>
                            </div>
                          );
                        })
                      ) : (
                        <div className="py-8 text-center font-mono text-xs text-stone-dim">
                          No category telemetry records present.
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Top Certified Field Technicians */}
                  <div className="border border-divider bg-graphite p-6 space-y-5">
                    <div className="flex items-center justify-between pb-3 border-b border-divider">
                      <div>
                        <h3 className="font-medium text-porcelain text-sm">Top Field Technicians</h3>
                        <p className="text-xs text-stone-muted">Ranked by verified completed assignments</p>
                      </div>
                      <span className="text-[10px] font-mono text-stone-dim uppercase">Leaderboard</span>
                    </div>

                    <div className="divide-y divide-divider">
                      {analytics?.topMechanics?.length > 0 ? (
                        analytics.topMechanics.map((tech: any, idx: number) => (
                          <div key={tech.id} className="py-3 flex items-center justify-between gap-4 first:pt-0 last:pb-0">
                            <div className="flex items-center gap-3">
                              <span className="font-mono text-xs text-stone-dim w-4">{idx + 1}.</span>
                              <div>
                                <div className="font-medium text-xs text-porcelain">{tech.name}</div>
                                <div className="text-[11px] font-mono text-stone-muted">{tech.email}</div>
                              </div>
                            </div>
                            <div className="text-right font-mono text-xs">
                              <div className="text-porcelain font-medium">{tech.totalJobsCompleted} Completed</div>
                              <div className="text-stone-dim text-[11px]">Radius: {tech.operatingRadiusKm} km</div>
                            </div>
                          </div>
                        ))
                      ) : (
                        <div className="py-8 text-center font-mono text-xs text-stone-dim">
                          No technician completions logged yet.
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </>
            )}
          </div>
        )}

        {/* ========================================================================= */}
        {/* TAB 2: FIELD TECHNICIAN CREDENTIAL GATE                                  */}
        {/* ========================================================================= */}
        {activeTab === 'mechanics' && (
          <div className="space-y-6">
            {/* Filter Bar */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2">
              <div className="flex items-center gap-2">
                <span className="text-xs font-mono uppercase text-stone-dim mr-2">Filter Status:</span>
                {['ALL', 'PENDING', 'APPROVED', 'REJECTED'].map((st) => (
                  <button
                    key={st}
                    onClick={() => {
                      setMechanicStatusFilter(st);
                      fetchMechanics(st);
                    }}
                    className={`px-3 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors border ${
                      mechanicStatusFilter === st
                        ? 'border-porcelain bg-porcelain text-carbon font-medium'
                        : 'border-divider bg-graphite text-stone-muted hover:text-porcelain'
                    }`}
                  >
                    {st}
                  </button>
                ))}
              </div>

              <button
                onClick={() => fetchMechanics(mechanicStatusFilter)}
                className="px-3 py-1.5 border border-divider hover:border-divider-strong bg-graphite text-xs font-mono text-stone-muted hover:text-porcelain flex items-center gap-2 transition-colors self-start sm:self-auto"
              >
                <RefreshCw className="w-3.5 h-3.5" />
                <span>Refresh Desk</span>
              </button>
            </div>

            {/* Mechanics Table */}
            {isLoadingMechanics ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted animate-pulse">
                Loading technician credentials registry...
              </div>
            ) : mechanics.length === 0 ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted">
                No technicians found matching filter &quot;{mechanicStatusFilter}&quot;.
              </div>
            ) : (
              <div className="border border-divider divide-y divide-divider bg-graphite">
                {mechanics.map((mech) => (
                  <div key={mech.id} className="p-6 flex flex-col md:flex-row md:items-center justify-between gap-6">
                    <div className="space-y-2">
                      <div className="flex flex-wrap items-center gap-2.5">
                        <span className="font-medium text-base text-porcelain">{mech.user?.fullName}</span>
                        <span className="text-stone-dim text-xs font-mono">•</span>
                        <span className="text-xs font-mono text-stone-muted">{mech.workshopName || 'Independent Mobile Unit'}</span>
                        
                        <span className={`px-2 py-0.5 rounded-sm border text-[10px] font-mono uppercase ${
                          mech.verificationStatus === 'APPROVED' 
                            ? 'border-sage/40 text-sage-light bg-sage-subtle' 
                            : mech.verificationStatus === 'PENDING'
                            ? 'border-ochre/40 text-ochre bg-ochre-subtle'
                            : 'border-crimson/40 text-crimson bg-crimson-subtle'
                        }`}>
                          {mech.verificationStatus}
                        </span>
                      </div>

                      <div className="text-xs font-mono text-stone-dim flex flex-wrap gap-x-4 gap-y-1">
                        <span>Email: <strong className="text-porcelain">{mech.user?.email}</strong></span>
                        <span>Phone: <strong className="text-porcelain">{mech.user?.phone || 'Not provided'}</strong></span>
                        <span>Trade License: <strong className="text-porcelain">{mech.licenseNumber || 'None specified'}</strong></span>
                        <span>Operating Radius: <strong className="text-porcelain">{mech.operatingRadiusKm} km</strong></span>
                        <span>Completed Jobs: <strong className="text-porcelain">{mech.totalJobsCompleted}</strong></span>
                      </div>

                      {mech.verificationNotes && (
                        <div className="text-xs font-mono text-stone-muted bg-carbon p-2.5 border border-divider/60">
                          <span className="text-stone-dim uppercase text-[10px] block">Audit Notes:</span>
                          {mech.verificationNotes}
                        </div>
                      )}
                    </div>

                    <div className="flex items-center gap-3 shrink-0">
                      <button
                        onClick={() => {
                          setSelectedMechanic(mech);
                          setReviewNotes(mech.verificationNotes || '');
                        }}
                        className="px-4 py-2 border border-divider hover:border-porcelain bg-elevated hover:bg-elevated-hover text-xs font-mono uppercase tracking-wider text-porcelain transition-colors"
                      >
                        Review Credentials
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Verification Modal Dialog */}
            {selectedMechanic && (
              <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
                <div className="max-w-xl w-full border border-divider bg-graphite p-6 space-y-6 shadow-architectural">
                  <div className="flex items-center justify-between pb-4 border-b border-divider">
                    <div>
                      <h3 className="text-lg font-medium text-porcelain">Review Field Technician Credentials</h3>
                      <p className="text-xs text-stone-muted font-mono">{selectedMechanic.user?.fullName} // {selectedMechanic.workshopName}</p>
                    </div>
                    <button onClick={() => setSelectedMechanic(null)} className="text-stone-dim hover:text-porcelain">
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  <div className="space-y-4 text-xs font-mono">
                    <div className="grid grid-cols-2 gap-3 bg-carbon p-4 border border-divider">
                      <div>
                        <div className="text-stone-dim uppercase text-[10px]">Trade License</div>
                        <div className="text-porcelain font-medium mt-1">{selectedMechanic.licenseNumber || 'N/A'}</div>
                      </div>
                      <div>
                        <div className="text-stone-dim uppercase text-[10px]">Operating Radius</div>
                        <div className="text-porcelain font-medium mt-1">{selectedMechanic.operatingRadiusKm} Kilometers</div>
                      </div>
                      <div>
                        <div className="text-stone-dim uppercase text-[10px]">Direct Email</div>
                        <div className="text-porcelain font-medium mt-1">{selectedMechanic.user?.email}</div>
                      </div>
                      <div>
                        <div className="text-stone-dim uppercase text-[10px]">Current Status</div>
                        <div className="text-ochre font-medium mt-1 uppercase">{selectedMechanic.verificationStatus}</div>
                      </div>
                    </div>

                    <div>
                      <label className="block text-[11px] uppercase tracking-wider text-stone-muted mb-2">
                        Supervisory Verification Notes & Audit Rationale
                      </label>
                      <textarea
                        rows={3}
                        value={reviewNotes}
                        onChange={(e) => setReviewNotes(e.target.value)}
                        placeholder="e.g. Trade license verified with State Bureau. ASE Master certification validated."
                        className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted"
                      />
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-4 border-t border-divider">
                    <button
                      type="button"
                      disabled={isSubmittingReview}
                      onClick={() => handleVerifyMechanic('REJECTED')}
                      className="px-4 py-2 border border-crimson/50 hover:bg-crimson-subtle text-crimson text-xs font-mono uppercase tracking-wider transition-colors disabled:opacity-50"
                    >
                      Reject Application
                    </button>

                    <div className="flex items-center gap-3">
                      <button
                        type="button"
                        onClick={() => setSelectedMechanic(null)}
                        className="px-4 py-2 border border-divider hover:border-divider-strong text-stone-muted text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        Cancel
                      </button>
                      <button
                        type="button"
                        disabled={isSubmittingReview}
                        onClick={() => handleVerifyMechanic('APPROVED')}
                        className="px-4 py-2 bg-sage hover:bg-sage-light text-porcelain text-xs font-mono uppercase tracking-wider transition-colors disabled:opacity-50 font-medium"
                      >
                        Approve Credentials
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* ========================================================================= */}
        {/* TAB 3: DISPUTE & GRIEVANCE DESK                                          */}
        {/* ========================================================================= */}
        {activeTab === 'disputes' && (
          <div className="space-y-6">
            {/* Filter Bar */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2">
              <div className="flex items-center gap-2 overflow-x-auto pb-1 sm:pb-0">
                <span className="text-xs font-mono uppercase text-stone-dim mr-2 shrink-0">Status:</span>
                {['ALL', 'PENDING', 'INVESTIGATING', 'RESOLVED', 'DISMISSED'].map((st) => (
                  <button
                    key={st}
                    onClick={() => {
                      setComplaintStatusFilter(st);
                      fetchComplaints(st);
                    }}
                    className={`px-3 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors border whitespace-nowrap ${
                      complaintStatusFilter === st
                        ? 'border-porcelain bg-porcelain text-carbon font-medium'
                        : 'border-divider bg-graphite text-stone-muted hover:text-porcelain'
                    }`}
                  >
                    {st}
                  </button>
                ))}
              </div>

              <button
                onClick={() => fetchComplaints(complaintStatusFilter)}
                className="px-3 py-1.5 border border-divider hover:border-divider-strong bg-graphite text-xs font-mono text-stone-muted hover:text-porcelain flex items-center gap-2 transition-colors self-start sm:self-auto shrink-0"
              >
                <RefreshCw className="w-3.5 h-3.5" />
                <span>Refresh Disputes</span>
              </button>
            </div>

            {/* Complaints List */}
            {isLoadingComplaints ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted animate-pulse">
                Querying Municipal Dispute Registry...
              </div>
            ) : complaints.length === 0 ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted">
                No disputes filed matching status &quot;{complaintStatusFilter}&quot;.
              </div>
            ) : (
              <div className="border border-divider divide-y divide-divider bg-graphite">
                {complaints.map((item) => (
                  <div key={item.id} className="p-6 space-y-4">
                    <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                      <div className="space-y-1.5">
                        <div className="flex items-center gap-2.5">
                          <span className={`px-2 py-0.5 rounded-sm border text-[10px] font-mono uppercase ${
                            item.status === 'RESOLVED'
                              ? 'border-sage/40 text-sage-light bg-sage-subtle'
                              : item.status === 'INVESTIGATING'
                              ? 'border-ochre/40 text-ochre bg-ochre-subtle'
                              : item.status === 'DISMISSED'
                              ? 'border-stone-dim/40 text-stone-dim bg-carbon'
                              : 'border-crimson/40 text-crimson bg-crimson-subtle'
                          }`}>
                            {item.status}
                          </span>
                          <h3 className="font-medium text-base text-porcelain">{item.subject}</h3>
                        </div>

                        <div className="text-xs font-mono text-stone-dim flex flex-wrap gap-x-4 gap-y-1">
                          <span>Filed By: <strong className="text-porcelain">{item.filedBy?.fullName} ({item.filedBy?.role})</strong></span>
                          <span>Target: <strong className="text-porcelain">{item.targetUser?.fullName || 'Assigned Technician'}</strong></span>
                          <span>Service ID: <strong className="text-porcelain font-mono">{item.serviceRequestId?.slice(0, 12)}...</strong></span>
                          <span>Date: <strong className="text-porcelain">{new Date(item.createdAt).toLocaleDateString()}</strong></span>
                        </div>
                      </div>

                      <button
                        onClick={() => {
                          setSelectedComplaint(item);
                          setNewComplaintStatus(item.status);
                          setComplaintResolutionNotes(item.resolutionNotes || '');
                        }}
                        className="px-4 py-2 border border-divider hover:border-porcelain bg-elevated hover:bg-elevated-hover text-xs font-mono uppercase tracking-wider text-porcelain transition-colors shrink-0"
                      >
                        Manage Dispute
                      </button>
                    </div>

                    <p className="text-xs text-stone-muted font-normal bg-carbon p-3 border border-divider/60">
                      {item.description}
                    </p>

                    {item.resolutionNotes && (
                      <div className="p-3 border border-sage/30 bg-sage-subtle text-xs font-mono space-y-1">
                        <span className="text-[10px] text-sage-light uppercase tracking-wider">Supervisory Resolution Notes:</span>
                        <div className="text-porcelain">{item.resolutionNotes}</div>
                        {item.resolvedAt && (
                          <div className="text-[10px] text-stone-dim">Resolved on {new Date(item.resolvedAt).toLocaleString()}</div>
                        )}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {/* Dispute Resolution Modal */}
            {selectedComplaint && (
              <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
                <div className="max-w-xl w-full border border-divider bg-graphite p-6 space-y-6 shadow-architectural">
                  <div className="flex items-center justify-between pb-4 border-b border-divider">
                    <div>
                      <h3 className="text-lg font-medium text-porcelain">Manage Municipal Dispute</h3>
                      <p className="text-xs text-stone-muted font-mono">{selectedComplaint.subject}</p>
                    </div>
                    <button onClick={() => setSelectedComplaint(null)} className="text-stone-dim hover:text-porcelain">
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  <div className="space-y-4 text-xs font-mono">
                    <div>
                      <label className="block text-[11px] uppercase tracking-wider text-stone-muted mb-2">
                        Supervisory Status Progression
                      </label>
                      <select
                        value={newComplaintStatus}
                        onChange={(e) => setNewComplaintStatus(e.target.value)}
                        className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted"
                      >
                        <option value="INVESTIGATING">INVESTIGATING — Evidence under review</option>
                        <option value="RESOLVED">RESOLVED — Formal reconciliation enacted</option>
                        <option value="DISMISSED">DISMISSED — Deemed unsubstantiated</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-[11px] uppercase tracking-wider text-stone-muted mb-2">
                        Resolution Notes & Final Determination
                      </label>
                      <textarea
                        rows={4}
                        value={complaintResolutionNotes}
                        onChange={(e) => setComplaintResolutionNotes(e.target.value)}
                        placeholder="Detail the investigation findings, arbitration decision, or remedial refund/action..."
                        className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted"
                      />
                    </div>
                  </div>

                  <div className="flex items-center justify-end gap-3 pt-4 border-t border-divider">
                    <button
                      type="button"
                      onClick={() => setSelectedComplaint(null)}
                      className="px-4 py-2 border border-divider hover:border-divider-strong text-stone-muted text-xs font-mono uppercase tracking-wider transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      disabled={isSubmittingComplaint}
                      onClick={handleUpdateComplaintStatus}
                      className="px-4 py-2 bg-porcelain hover:bg-porcelain-dim text-carbon text-xs font-mono uppercase tracking-wider transition-colors disabled:opacity-50 font-medium"
                    >
                      Commit Resolution
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* ========================================================================= */}
        {/* TAB 4: SECURITY AUDIT LOG EXPLORER                                       */}
        {/* ========================================================================= */}
        {activeTab === 'audit-logs' && (
          <div className="space-y-6">
            {/* Search & Filter Controls */}
            <div className="p-4 border border-divider bg-graphite flex flex-col md:flex-row items-center gap-4">
              <div className="flex-1 w-full relative">
                <Search className="w-4 h-4 text-stone-dim absolute left-3 top-3" />
                <input
                  type="text"
                  value={auditActionFilter}
                  onChange={(e) => setAuditActionFilter(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && fetchAuditLogs(0)}
                  placeholder="Filter by action name (e.g. MECHANIC_VERIFICATION, COMPLAINT, etc.)..."
                  className="w-full pl-9 pr-3 py-2 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted"
                />
              </div>

              <div className="w-full md:w-56">
                <select
                  value={auditEntityFilter}
                  onChange={(e) => {
                    setAuditEntityFilter(e.target.value);
                  }}
                  className="w-full px-3 py-2 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted"
                >
                  <option value="">All Entity Types</option>
                  <option value="MechanicProfile">MechanicProfile</option>
                  <option value="Complaint">Complaint</option>
                  <option value="ServiceRequest">ServiceRequest</option>
                  <option value="BreakdownReport">BreakdownReport</option>
                  <option value="User">User</option>
                </select>
              </div>

              <button
                onClick={() => fetchAuditLogs(0)}
                className="w-full md:w-auto px-4 py-2 bg-porcelain hover:bg-porcelain-dim text-carbon text-xs font-mono uppercase tracking-wider transition-colors font-medium shrink-0"
              >
                Apply Filters
              </button>
            </div>

            {/* Audit Logs Table */}
            {isLoadingAudit ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted animate-pulse">
                Querying PostgreSQL Immutable Audit Log Ledger...
              </div>
            ) : auditLogs.length === 0 ? (
              <div className="p-16 border border-divider bg-graphite text-center font-mono text-xs text-stone-muted">
                No audit log entries found matching criteria.
              </div>
            ) : (
              <div className="border border-divider bg-graphite overflow-x-auto">
                <table className="w-full text-left font-mono text-xs">
                  <thead className="border-b border-divider bg-carbon/60 text-stone-dim uppercase text-[10px]">
                    <tr>
                      <th className="p-3.5">Timestamp</th>
                      <th className="p-3.5">Operator</th>
                      <th className="p-3.5">Action Executed</th>
                      <th className="p-3.5">Target Entity</th>
                      <th className="p-3.5 text-right">Details</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-divider">
                    {auditLogs.map((log) => (
                      <tr key={log.id} className="hover:bg-elevated/40 transition-colors">
                        <td className="p-3.5 text-stone-muted whitespace-nowrap">
                          {new Date(log.timestamp).toLocaleString()}
                        </td>
                        <td className="p-3.5 whitespace-nowrap">
                          <div className="text-porcelain font-medium">{log.user?.fullName || 'System / Service'}</div>
                          <div className="text-[10px] text-stone-dim">{log.user?.email || 'N/A'} • {log.user?.role || 'SYSTEM'}</div>
                        </td>
                        <td className="p-3.5 whitespace-nowrap">
                          <span className="px-2 py-0.5 border border-divider text-porcelain bg-carbon text-[11px]">
                            {log.action}
                          </span>
                        </td>
                        <td className="p-3.5 text-stone-muted whitespace-nowrap">
                          {log.entityName} <span className="text-[10px] text-stone-dim">({log.entityId?.slice(0, 8)}...)</span>
                        </td>
                        <td className="p-3.5 text-right whitespace-nowrap">
                          <button
                            onClick={() => setInspectingLog(log)}
                            className="px-2.5 py-1 border border-divider hover:border-porcelain bg-carbon text-stone-muted hover:text-porcelain text-[10px] uppercase tracking-wider transition-colors inline-flex items-center gap-1.5"
                          >
                            <Eye className="w-3 h-3" />
                            <span>Inspect</span>
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {/* Pagination Strip */}
            <div className="flex items-center justify-between text-xs font-mono text-stone-muted pt-2">
              <div>
                Showing {auditLogs.length} of {auditPagination.total} logged audit records
              </div>
              <div className="flex items-center gap-2">
                <button
                  disabled={auditPagination.offset === 0 || isLoadingAudit}
                  onClick={() => fetchAuditLogs(Math.max(0, auditPagination.offset - auditPagination.limit))}
                  className="px-3 py-1.5 border border-divider hover:border-divider-strong bg-graphite text-porcelain disabled:opacity-40 transition-colors flex items-center gap-1"
                >
                  <ChevronLeft className="w-3.5 h-3.5" />
                  <span>Previous</span>
                </button>
                <button
                  disabled={!auditPagination.hasMore || isLoadingAudit}
                  onClick={() => fetchAuditLogs(auditPagination.offset + auditPagination.limit)}
                  className="px-3 py-1.5 border border-divider hover:border-divider-strong bg-graphite text-porcelain disabled:opacity-40 transition-colors flex items-center gap-1"
                >
                  <span>Next</span>
                  <ChevronRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            {/* Audit Payload JSON Inspector Modal */}
            {inspectingLog && (
              <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
                <div className="max-w-2xl w-full border border-divider bg-graphite p-6 space-y-4 shadow-architectural">
                  <div className="flex items-center justify-between pb-3 border-b border-divider">
                    <div>
                      <h3 className="text-base font-medium text-porcelain">Immutable Audit Payload</h3>
                      <p className="text-xs font-mono text-stone-dim">{inspectingLog.action} // ID: {inspectingLog.id}</p>
                    </div>
                    <button onClick={() => setInspectingLog(null)} className="text-stone-dim hover:text-porcelain">
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  <div className="space-y-3 font-mono text-xs">
                    <div className="grid grid-cols-2 gap-2 bg-carbon p-3 border border-divider text-[11px]">
                      <div>
                        <span className="text-stone-dim uppercase">Recorded:</span>
                        <div className="text-porcelain">{new Date(inspectingLog.timestamp).toISOString()}</div>
                      </div>
                      <div>
                        <span className="text-stone-dim uppercase">Operator:</span>
                        <div className="text-porcelain">{inspectingLog.user?.email || 'SYSTEM'}</div>
                      </div>
                      <div>
                        <span className="text-stone-dim uppercase">Entity:</span>
                        <div className="text-porcelain">{inspectingLog.entityName}</div>
                      </div>
                      <div>
                        <span className="text-stone-dim uppercase">Entity ID:</span>
                        <div className="text-porcelain">{inspectingLog.entityId || 'N/A'}</div>
                      </div>
                    </div>

                    <div>
                      <span className="text-stone-dim uppercase text-[10px] block mb-1">Details JSON Payload:</span>
                      <pre className="p-4 bg-carbon border border-divider text-stone-muted text-[11px] overflow-x-auto max-h-64 selection:bg-porcelain selection:text-carbon">
                        {JSON.stringify(inspectingLog.details, null, 2)}
                      </pre>
                    </div>
                  </div>

                  <div className="flex justify-end pt-3 border-t border-divider">
                    <button
                      onClick={() => setInspectingLog(null)}
                      className="px-4 py-2 bg-porcelain text-carbon text-xs font-mono uppercase tracking-wider font-medium"
                    >
                      Close Inspector
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

      </main>
    </div>
  );
}
