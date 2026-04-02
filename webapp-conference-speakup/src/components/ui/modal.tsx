"use client";

import { Fragment } from "react";
import { cn } from "@/lib/utils";
import { X } from "lucide-react";
import { Button } from "./button";

interface ModalProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  description?: string;
  children?: React.ReactNode;
  danger?: boolean;
  confirmLabel?: string;
  cancelLabel?: string;
  onConfirm?: () => void;
  loading?: boolean;
}

export function Modal({
  open,
  onClose,
  title,
  description,
  children,
  danger,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  onConfirm,
  loading,
}: ModalProps) {
  if (!open) return null;

  return (
    <Fragment>
      {/* Overlay */}
      <div
        className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm animate-in fade-in"
        onClick={onClose}
      />
      {/* Dialog */}
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div
          className={cn(
            "relative w-full max-w-md rounded-2xl border border-border bg-card p-6 shadow-xl",
            "animate-in zoom-in-95 fade-in duration-200"
          )}
          onClick={(e) => e.stopPropagation()}
        >
          <button
            onClick={onClose}
            className="absolute right-4 top-4 text-muted hover:text-text-primary transition-colors"
          >
            <X size={18} />
          </button>

          {title && (
            <h2 className="text-lg font-semibold text-text-primary pr-8">
              {title}
            </h2>
          )}
          {description && (
            <p className="mt-1.5 text-sm text-text-secondary">{description}</p>
          )}

          {children && <div className="mt-4">{children}</div>}

          {onConfirm && (
            <div className="mt-6 flex gap-3 justify-end">
              <Button variant="secondary" size="sm" onClick={onClose}>
                {cancelLabel}
              </Button>
              <Button
                variant={danger ? "danger" : "primary"}
                size="sm"
                onClick={onConfirm}
                loading={loading}
              >
                {confirmLabel}
              </Button>
            </div>
          )}
        </div>
      </div>
    </Fragment>
  );
}
