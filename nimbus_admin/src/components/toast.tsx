'use client';

import { createContext, ReactNode, useCallback, useContext, useEffect, useRef, useState } from 'react';
import {
  FiAlertCircle, FiAlertTriangle, FiCheckCircle, FiInfo, FiX,
} from 'react-icons/fi';

export type ToastKind = 'success' | 'error' | 'warning' | 'info';
export type PendingKind = 'create' | 'update' | 'delete' | 'save' | 'submit';

export interface ToastItem {
  id: number;
  kind: ToastKind;
  title: string;
  message?: string;
}

const TOAST_STYLE: Record<ToastKind, string> = {
  success: 'bg-emerald-600',
  error: 'bg-rose-600',
  warning: 'bg-amber-500',
  info: 'bg-indigo-600',
};

const TOAST_ICON: Record<ToastKind, ReactNode> = {
  success: <FiCheckCircle className="w-5 h-5 shrink-0" />,
  error: <FiAlertCircle className="w-5 h-5 shrink-0" />,
  warning: <FiAlertTriangle className="w-5 h-5 shrink-0" />,
  info: <FiInfo className="w-5 h-5 shrink-0" />,
};

interface ToastContextValue {
  /** Show a toast. Auto-dismisses after 4.5s (error: 7s). */
  toast: (kind: ToastKind, title: string, message?: string) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

/**
 * Global toast host. Mount once in the root layout; every page can push
 * cached-operation feedback (created / saved / deleted / rejected / errors).
 */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([]);
  const nextId = useRef(1);

  const dismiss = useCallback((id: number) => {
    setItems((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const toast = useCallback(
    (kind: ToastKind, title: string, message?: string) => {
      const id = nextId.current++;
      setItems((prev) => [...prev.slice(-3), { id, kind, title, message }]);
      const ttl = kind === 'error' ? 7000 : 4500;
      setTimeout(() => dismiss(id), ttl);
    },
    [dismiss],
  );

  return (
    <ToastContext.Provider value={{ toast }}>
      {children}
      {/* Toast stack — bottom-right, above everything */}
      <div className="fixed bottom-4 right-4 z-[60] flex flex-col gap-2 w-80 max-w-[90vw]">
        {items.map((t) => (
          <div
            key={t.id}
            role="status"
            className={`${TOAST_STYLE[t.kind]} text-white rounded-lg shadow-lg px-4 py-3 flex items-start gap-3 animate-[fadeIn_.15s_ease-out]`}
          >
            {TOAST_ICON[t.kind]}
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold leading-5">{t.title}</p>
              {t.message && <p className="text-xs opacity-90 mt-0.5 break-words">{t.message}</p>}
            </div>
            <button
              onClick={() => dismiss(t.id)}
              className="opacity-70 hover:opacity-100 shrink-0"
              aria-label="Dismiss"
            >
              <FiX className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export const useToast = (): ToastContextValue => {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast must be used inside <ToastProvider>');
  return ctx;
};

// ────────────────────────────────────────────────
// Spinner shared by confirming/working modal states
// ────────────────────────────────────────────────

/** Suffix helper for "verb" + ": " lines, e.g. "Deleting: <id>". */
export const pendingText = (verb: string, target?: string): string =>
  target ? `${verb}: ${target}` : verb;

interface ConfirmDialogProps {
  open: boolean;
  tone?: 'normal' | 'danger';
  title: string;
  message?: string;
  /** Label of the positive action, e.g. "Delete", "Refund" */
  confirmLabel?: string;
  /** While the request is in flight, shows "Saving…" etc. and disables everything */
  working?: boolean;
  /** Extra text shown while working, defaults to the -ing form */
  workingLabel?: string;
  confirmOnCloseOnly?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

/** "Delete" -> "Deleting", "Reject" -> "Rejecting", "Save" -> "Saving", fallback "Confirming". */
const ingForm = (label: string): string => {
  if (/e$/i.test(label)) return `${label.slice(0, -1)}ing`;
  return `${label}ing`;
};

/**
 * Modal used for confirmation prompts and to reflect the in-flight state of a
 * CRUD action ("Saving…"). Disabled while `working` to prevent double-submit.
 */
export function ConfirmDialog({
  open,
  tone = 'normal',
  title,
  message,
  confirmLabel = 'Confirm',
  working = false,
  workingLabel,
  onConfirm,
  onCancel,
}: ConfirmDialogProps) {
  // Escape key closes while not working.
  useEffect(() => {
    if (!open || working) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onCancel();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, working, onCancel]);

  if (!open) return null;

  const toneClasses = tone === 'danger'
    ? 'bg-rose-600 hover:bg-rose-700'
    : 'bg-indigo-600 hover:bg-indigo-700';

  return (
    <div
      className="fixed inset-0 z-[70] flex items-center justify-center bg-black/50 p-4"
      onClick={() => !working && onCancel()}
    >
      <div
        className="bg-white rounded-xl shadow-xl w-full max-w-sm p-6"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
      >
        <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
        {message && <p className="text-sm text-gray-600 mt-2 whitespace-pre-line">{message}</p>}

        <div className="flex items-center justify-end gap-2 mt-6">
          <button
            onClick={onCancel}
            disabled={working}
            className="px-4 py-2 text-sm rounded-md border border-gray-300 text-gray-700 hover:bg-gray-50 disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            disabled={working}
            className={`px-4 py-2 text-sm rounded-md text-white disabled:opacity-60 flex items-center gap-2 ${toneClasses}`}
          >
            {working && (
              <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
            )}
            {working ? `${workingLabel ?? ingForm(confirmLabel)}…` : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
