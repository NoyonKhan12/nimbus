'use client';

import { useEffect, useState } from 'react';
import { FiSliders, FiRefreshCw, FiSave } from 'react-icons/fi';
import { SystemConfigInfo } from '@/types';
import { getConfigurations, updateConfiguration } from '@/services/config';
import { formatDateTime } from '@/lib/utils';
import { useToast } from '@/components/toast';

/**
 * System configuration page — table of operational configuration keys with
 * inline editable value fields and a save button per row.
 */
export default function ConfigPage() {
  const [configs, setConfigs] = useState<SystemConfigInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  /** Draft values by key while being edited (only set when touched). */
  const [drafts, setDrafts] = useState<Record<string, string>>({});
  const [savingKey, setSavingKey] = useState<string | null>(null);
  const { toast } = useToast();

  const loadConfigs = async () => {
    try {
      setLoading(true);
      const list: SystemConfigInfo[] = await getConfigurations();
      setConfigs(list);
      setDrafts({});
      setError(null);
    } catch (err: any) {
      setError(err.response?.data?.message || err.message || 'Failed to load configuration');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadConfigs();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleValueChange = (configKey: string, value: string) => {
    setDrafts((prev) => ({ ...prev, [configKey]: value }));
  };

  const isDirty = (config: SystemConfigInfo): boolean => {
    const draft = drafts[config.configKey];
    return (
      draft !== undefined &&
      draft !== (config.configValue ?? '')
    );
  };

  const handleSave = async (config: SystemConfigInfo) => {
    if (!isDirty(config) || savingKey) return;
    try {
      setSavingKey(config.configKey);
      const updated = await updateConfiguration(
        config.configKey,
        drafts[config.configKey],
      );
      setConfigs((prev) =>
        prev.map((c) => (c.configKey === updated.configKey ? updated : c)),
      );
      setDrafts((prev) => {
        const next = { ...prev };
        delete next[config.configKey];
        return next;
      });
      toast('success', 'Configuration saved',
        `${config.configKey} is now "${drafts[config.configKey]}".`);
    } catch (err: any) {
      toast('error', 'Save failed',
        err?.response?.data?.message ||
          `Failed to update configuration ${config.configKey}`);
    } finally {
      setSavingKey(null);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <FiSliders className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Configuration</h1>
        </div>
        <button
          onClick={loadConfigs}
          className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
        >
          <FiRefreshCw className="text-sm" />
          Refresh
        </button>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg">{error}</div>
      )}

      <div className="overflow-x-auto bg-white rounded-xl shadow">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 text-left">
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Key</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Value</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Type</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Description</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Updated</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading
              ? [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-40"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-32"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-48"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-32"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                  </tr>
                ))
              : configs.length === 0
              ? (
                  <tr>
                    <td colSpan={6} className="px-4 py-6 text-sm text-gray-500 text-center">
                      No configuration entries found
                    </td>
                  </tr>
                )
              : configs.map((config) => (
                  <tr key={config.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-700 font-mono">
                      {config.configKey}
                      {config.encrypted && (
                        <span className="ml-1 text-xs text-gray-400" title="Encrypted">
                          🔒
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-sm w-64">
                      <input
                        type="text"
                        value={drafts[config.configKey] ?? (config.configValue ?? '')}
                        onChange={(e) =>
                          handleValueChange(config.configKey, e.target.value)
                        }
                        className={`px-2 py-1 border rounded text-sm w-full focus:ring-2 focus:ring-indigo-500 ${
                          isDirty(config)
                            ? 'border-indigo-400 bg-indigo-50'
                            : 'border-gray-300'
                        }`}
                      />
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      <span className="status-badge bg-gray-100 text-gray-800">
                        {config.configType}
                      </span>
                    </td>
                    <td
                      className="px-4 py-3 text-sm text-gray-500 max-w-xs truncate"
                      title={config.description ?? ''}
                    >
                      {config.description ?? '-'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">
                      {formatDateTime(config.updatedAt)}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => handleSave(config)}
                        disabled={!isDirty(config) || savingKey === config.configKey}
                        className="text-xs px-2 py-1 bg-emerald-100 text-emerald-700 rounded hover:bg-emerald-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-1"
                      >
                        <FiSave className="text-xs" />
                        {savingKey === config.configKey ? 'Saving…' : 'Save'}
                      </button>
                    </td>
                  </tr>
                ))}
          </tbody>
        </table>
      </div>

      {!loading && configs.length > 0 && (
        <p className="mt-4 text-sm text-gray-500">
          {configs.length} configuration entr{configs.length === 1 ? 'y' : 'ies'}
        </p>
      )}
    </div>
  );
}
